<#
.SYNOPSIS
    Provisions a secure Azure Storage Account and Blob Container for Terraform Remote State.

.DESCRIPTION
    Creates:
    1. Dedicated Resource Group for Terraform State Management
    2. Storage Account with TLS 1.2, Blob Versioning, and Soft Delete protection
    3. Private Blob Container ('tfstate')
    4. Outputs configuration parameters ready for Azure DevOps pipeline variables.

.EXAMPLE
    .\setup-tfstate-storage.ps1 -ResourceGroupName "rg-terraform-state-mgmt" -Location "eastus"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupName = "rg-terraform-state-mgmt",

    [Parameter(Mandatory = $false)]
    [string]$Location = "eastus",

    # Must be 3-24 lowercase letters and numbers, globally unique across Azure
    [Parameter(Mandatory = $false)]
    [string]$StorageAccountName = "",

    [Parameter(Mandatory = $false)]
    [string]$ContainerName = "tfstate"
)

$ErrorActionPreference = "Stop"

# Auto-generate unique storage name if not supplied
if (-not $StorageAccountName) {
    $randomHex = [System.Guid]::NewGuid().ToString("N").Substring(0, 6)
    $StorageAccountName = "sttfstate$randomHex"
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "PROVISIONING TERRAFORM REMOTE STATE STORAGE IN AZURE" -ForegroundColor Cyan
Write-Host "Resource Group   : $ResourceGroupName" -ForegroundColor Yellow
Write-Host "Location         : $Location" -ForegroundColor Yellow
Write-Host "Storage Account  : $StorageAccountName" -ForegroundColor Yellow
Write-Host "Container Name   : $ContainerName" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Create Resource Group
Write-Host "`n[1/4] Ensuring Resource Group '$ResourceGroupName' exists..." -ForegroundColor Green
az group create `
    --name $ResourceGroupName `
    --location $Location `
    --output table

# 2. Create Storage Account with Security Best Practices
Write-Host "`n[2/4] Provisioning Storage Account '$StorageAccountName'..." -ForegroundColor Green
az storage account create `
    --resource-group $ResourceGroupName `
    --name $StorageAccountName `
    --location $Location `
    --sku Standard_LRS `
    --kind StorageV2 `
    --min-tls-version TLS1_2 `
    --https-only true `
    --allow-blob-public-access false `
    --output table

# 3. Enable Blob Versioning and Soft Delete (Critical for State Protection)
Write-Host "`n[3/4] Enabling Blob Versioning and 14-day Soft Delete..." -ForegroundColor Green
az storage account blob-service-properties update `
    --resource-group $ResourceGroupName `
    --account-name $StorageAccountName `
    --enable-versioning true `
    --enable-delete-retention true `
    --delete-retention-days 14 `
    --output none

# 4. Create Private Container for State Files
Write-Host "`n[4/4] Creating Blob Container '$ContainerName'..." -ForegroundColor Green
az storage container create `
    --name $ContainerName `
    --account-name $StorageAccountName `
    --auth-mode login `
    --output table

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host "SUCCESS! Terraform State Storage is Ready!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Use these values in Azure DevOps Library / Pipeline Variables:" -ForegroundColor Yellow
Write-Host "TF_STATE_RG             : $ResourceGroupName" -ForegroundColor White
Write-Host "TF_STATE_STORAGE_ACCOUNT: $StorageAccountName" -ForegroundColor White
Write-Host "TF_STATE_CONTAINER      : $ContainerName" -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor Cyan
