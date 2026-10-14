<#
.SYNOPSIS
    Automated runner for On-Demand workloads with isolated state and PR/ticket tracking.

.DESCRIPTION
    Deploys or destroys transient, ad-hoc, or on-demand VMs, SQL databases,
    or storage accounts inside the existing base VNet using an independent state file
    keyed by Workload ID or PR number.

.EXAMPLE
    # Deploy for PR 104 using a cataloged template
    .\deploy-on-demand.ps1 -WorkloadId "pr-104" -VarFile "workloads/pr-template.tfvars" -Action apply

    # Deploy for an ad-hoc analytics workload
    .\deploy-on-demand.ps1 -WorkloadId "analytics-heavy" -VarFile "workloads/analytics-heavy.tfvars" -Action apply

    # Destroy ONLY PR 104's resources
    .\deploy-on-demand.ps1 -WorkloadId "pr-104" -Action destroy
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$WorkloadId = "sandbox",

    [Parameter(Mandatory = $false)]
    [ValidateSet("init", "plan", "apply", "destroy", "output", "refresh-only")]
    [string]$Action = "plan",

    [Parameter(Mandatory = $false)]
    [string]$VarFile = "on-demand.tfvars",

    [Parameter(Mandatory = $false)]
    [string]$BackendResourceGroup = "",

    [Parameter(Mandatory = $false)]
    [string]$BackendStorageAccount = "",

    [Parameter(Mandatory = $false)]
    [string]$BackendContainer = "tfstate"
)

$ErrorActionPreference = "Stop"

$DefaultDir = Join-Path $PSScriptRoot "..\terraform\on-demand"
if (Test-Path $DefaultDir) {
    $OnDemandDir = (Resolve-Path $DefaultDir).Path
} else {
    $OnDemandDir = "d:\[REDACTED]\Project\terraform\on-demand"
}
$PlanFile = "$OnDemandDir\tfplan-$WorkloadId"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "ON-DEMAND WORKLOAD RUNNER (ISOLATED TFSTATE)" -ForegroundColor Cyan
Write-Host "Workload / PR ID : $WorkloadId" -ForegroundColor Yellow
Write-Host "Action           : $Action" -ForegroundColor Yellow
Write-Host "Var File         : $VarFile" -ForegroundColor Yellow
Write-Host "State Key        : on-demand/$WorkloadId.terraform.tfstate" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

Set-Location -Path $OnDemandDir

# 1. Initialize Backend
if ($BackendStorageAccount -ne "") {
    Write-Host "`n[1/2] Initializing Azure Remote Backend for workload '$WorkloadId'..." -ForegroundColor Green
    terraform init `
        -backend-config="resource_group_name=$BackendResourceGroup" `
        -backend-config="storage_account_name=$BackendStorageAccount" `
        -backend-config="container_name=$BackendContainer" `
        -backend-config="key=on-demand/$WorkloadId.terraform.tfstate" `
        -reconfigure
} else {
    Write-Host "`n[1/2] Initializing local state for workload '$WorkloadId'..." -ForegroundColor Green
    terraform init
    # Switch or create workspace for this workload to isolate local state
    terraform workspace select "$WorkloadId" 2>$null
    if ($LASTEXITCODE -ne 0) {
        terraform workspace new "$WorkloadId"
    }
}

# 2. Plan / Apply
if ($Action -eq "plan" -or $Action -eq "apply") {
    Write-Host "`n[2/2] Generating Execution Plan for '$WorkloadId'..." -ForegroundColor Green
    terraform plan -var-file="$VarFile" -var="workload_id=$WorkloadId" -out="$PlanFile"
}

if ($Action -eq "apply") {
    Write-Host "`nApplying On-Demand Infrastructure for '$WorkloadId'..." -ForegroundColor Green
    terraform apply "$PlanFile"
}

if ($Action -eq "destroy") {
    Write-Host "`n⚠️ Destroying ONLY On-Demand resources for '$WorkloadId'..." -ForegroundColor Yellow
    Write-Host "Notice: Base Resource Group, VNet, and AKS are in a separate state and will NOT be touched." -ForegroundColor DarkGray
    terraform destroy -var-file="$VarFile" -var="workload_id=$WorkloadId"
}

if ($Action -eq "output") {
    terraform output
}

if ($Action -eq "refresh-only") {
    Write-Host "`n🔄 Syncing live cloud state into tfstate for '$WorkloadId' (no resource changes)..." -ForegroundColor Magenta
    terraform apply -refresh-only -var-file="$VarFile" -var="workload_id=$WorkloadId"
}
