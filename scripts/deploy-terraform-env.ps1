<#
.SYNOPSIS
    Automated multi-environment & selective-component Terraform runner script.

.DESCRIPTION
    Runs Terraform commands (init, plan, apply, destroy) for a specific target
    environment (dev, qa, prod) using environment-specific .tfvars files,
    remote state key isolation, and selective component deployment (AKS, VM, SQL, Storage).

.EXAMPLE
    # Deploy ONLY AKS in dev
    .\deploy-terraform-env.ps1 -Environment dev -Component aks -Action apply

    # Deploy ONLY VM in dev
    .\deploy-terraform-env.ps1 -Environment dev -Component vm -Action apply

    # Deploy ONLY SQL in dev
    .\deploy-terraform-env.ps1 -Environment dev -Component sql -Action apply

    # Deploy ALL components in dev
    .\deploy-terraform-env.ps1 -Environment dev -Component all -Action apply

    # Use native Terraform -target flag
    .\deploy-terraform-env.ps1 -Environment dev -Target "module.aks" -Action apply
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("dev", "qa", "prod")]
    [string]$Environment,

    [Parameter(Mandatory = $false)]
    [ValidateSet("all", "aks", "vm", "sql", "storage")]
    [string]$Component = "all",

    [Parameter(Mandatory = $false)]
    [ValidateSet("init", "plan", "apply", "destroy", "output", "refresh-only")]
    [string]$Action = "plan",

    # Optional native -target override (e.g., "module.compute_vm")
    [Parameter(Mandatory = $false)]
    [string]$Target = "",

    # Optional remote backend storage account configuration
    [Parameter(Mandatory = $false)]
    [string]$BackendResourceGroup = "",

    [Parameter(Mandatory = $false)]
    [string]$BackendStorageAccount = "",

    [Parameter(Mandatory = $false)]
    [string]$BackendContainer = "tfstate"
)

$ErrorActionPreference = "Stop"

$TerraformDir = "d:\Dinesh\Project\terraform\main-environments"
$VarFile = "$TerraformDir\environments\$Environment.tfvars"
$PlanFile = "$TerraformDir\tfplan-$Environment"

if (-not (Test-Path $VarFile)) {
    throw "Variable file for environment '$Environment' not found at: $VarFile"
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "TERRAFORM MULTI-ENVIRONMENT & COMPONENT RUNNER" -ForegroundColor Cyan
Write-Host "Environment : $Environment" -ForegroundColor Yellow
Write-Host "Component   : $Component" -ForegroundColor Yellow
Write-Host "Action      : $Action" -ForegroundColor Yellow
Write-Host "Var File    : $VarFile" -ForegroundColor Yellow
if ($Target) { Write-Host "Target Flag : $Target" -ForegroundColor Yellow }
Write-Host "==========================================================" -ForegroundColor Cyan

Set-Location -Path $TerraformDir

# -----------------------------------------------------------------------------
# 1. Build Component-Specific Variable Arguments
# -----------------------------------------------------------------------------
$componentVarFlags = @()

switch ($Component) {
    "aks" {
        Write-Host "Configuring selective deployment: [AKS only]" -ForegroundColor Magenta
        $componentVarFlags = @(
            "-var=enable_aks=true",
            "-var=enable_vm=false",
            "-var=enable_sql=false",
            "-var=enable_storage=false"
        )
    }
    "vm" {
        Write-Host "Configuring selective deployment: [Compute VM only]" -ForegroundColor Magenta
        $componentVarFlags = @(
            "-var=enable_vm=true",
            "-var=enable_aks=false",
            "-var=enable_sql=false",
            "-var=enable_storage=false"
        )
    }
    "sql" {
        Write-Host "Configuring selective deployment: [Azure SQL DB only]" -ForegroundColor Magenta
        $componentVarFlags = @(
            "-var=enable_sql=true",
            "-var=enable_aks=false",
            "-var=enable_vm=false",
            "-var=enable_storage=false"
        )
    }
    "storage" {
        Write-Host "Configuring selective deployment: [Storage Account only]" -ForegroundColor Magenta
        $componentVarFlags = @(
            "-var=enable_storage=true",
            "-var=enable_aks=false",
            "-var=enable_vm=false",
            "-var=enable_sql=false"
        )
    }
    "all" {
        Write-Host "Configuring deployment: [All Services Enabled]" -ForegroundColor Magenta
        # Defaults in .tfvars or variables.tf will apply
    }
}

# -----------------------------------------------------------------------------
# 2. Initialize Terraform (with Environment State Isolation)
# -----------------------------------------------------------------------------
if ($Action -eq "init" -or -not (Test-Path "$TerraformDir\.terraform")) {
    Write-Host "`n[1/3] Initializing Terraform for '$Environment'..." -ForegroundColor Green
    
    if ($BackendStorageAccount -ne "") {
        Write-Host "Configuring remote Azure Backend (Key: main-environments/$Environment.terraform.tfstate)..." -ForegroundColor DarkGray
        terraform init `
            -backend-config="resource_group_name=$BackendResourceGroup" `
            -backend-config="storage_account_name=$BackendStorageAccount" `
            -backend-config="container_name=$BackendContainer" `
            -backend-config="key=main-environments/$Environment.terraform.tfstate" `
            -reconfigure
    } else {
        Write-Host "Configuring local environment workspace for '$Environment'..." -ForegroundColor DarkGray
        terraform init
        # Ensure separate local state via workspaces (terraform.tfstate.d/<env>/terraform.tfstate)
        terraform workspace select "$Environment" 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Creating new local state workspace: '$Environment'..." -ForegroundColor Cyan
            terraform workspace new "$Environment"
        }
    }
} else {
    # If already initialized, make sure the correct workspace is selected
    if ($BackendStorageAccount -eq "") {
        terraform workspace select "$Environment" 2>$null
        if ($LASTEXITCODE -ne 0) {
            terraform workspace new "$Environment"
        }
    }
}

# -----------------------------------------------------------------------------
# 3. Plan
# -----------------------------------------------------------------------------
if ($Action -eq "plan" -or $Action -eq "apply") {
    Write-Host "`n[2/3] Generating Execution Plan for '$Environment' ($Component)..." -ForegroundColor Green
    
    $planArgs = @("plan", "-var-file=$VarFile")
    if ($componentVarFlags.Count -gt 0) {
        $planArgs += $componentVarFlags
    }
    if ($Target -ne "") {
        $planArgs += "-target=$Target"
    }
    $planArgs += "-out=$PlanFile"

    terraform @planArgs
}

# -----------------------------------------------------------------------------
# 4. Apply
# -----------------------------------------------------------------------------
if ($Action -eq "apply") {
    if ($Environment -eq "prod") {
        Write-Host "`n⚠️ WARNING: You are about to apply changes to the PRODUCTION environment!" -ForegroundColor Red
        $confirm = Read-Host "Type 'PROD' to confirm deployment"
        if ($confirm -ne "PROD") {
            Write-Warning "Deployment cancelled by user."
            exit 1
        }
    }

    Write-Host "`n[3/3] Applying Plan to '$Environment' ($Component)..." -ForegroundColor Green
    terraform apply "$PlanFile"
}

# -----------------------------------------------------------------------------
# 5. Destroy
# -----------------------------------------------------------------------------
if ($Action -eq "destroy") {
    Write-Host "`n⚠️ CAUTION: You are destroying resources in '$Environment' ($Component)!" -ForegroundColor Red
    $confirm = Read-Host "Type '$Environment' to confirm resource destruction"
    if ($confirm -eq $Environment) {
        $destroyArgs = @("destroy", "-var-file=$VarFile")
        if ($componentVarFlags.Count -gt 0) {
            $destroyArgs += $componentVarFlags
        }
        if ($Target -ne "") {
            $destroyArgs += "-target=$Target"
        }
        terraform @destroyArgs
    } else {
        Write-Warning "Destroy action cancelled."
    }
}

# -----------------------------------------------------------------------------
# 6. Output
# -----------------------------------------------------------------------------
if ($Action -eq "output") {
    terraform output
}

# -----------------------------------------------------------------------------
# 7. Refresh-Only (Update tfstate without modifying cloud resources)
# -----------------------------------------------------------------------------
if ($Action -eq "refresh-only") {
    Write-Host "`n🔄 Syncing live cloud state into tfstate (no resource changes)..." -ForegroundColor Magenta
    $refreshArgs = @("apply", "-refresh-only", "-var-file=$VarFile")
    if ($componentVarFlags.Count -gt 0) {
        $refreshArgs += $componentVarFlags
    }
    if ($Target -ne "") {
        $refreshArgs += "-target=$Target"
    }
    terraform @refreshArgs
}
