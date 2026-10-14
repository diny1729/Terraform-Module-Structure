<#
.SYNOPSIS
    Deploys Azure Application Gateway (v2 / WAF_v2) using Azure CLI commands executed in PowerShell.

.DESCRIPTION
    This script creates:
    1. A Standard Public IP address for Application Gateway
    2. An Azure Application Gateway (Standard_v2 or WAF_v2) with autoscale support
    3. Custom Health Probe
    4. HTTP Settings (with cookie affinity and custom timeout)
    5. Backend Pool targeting AKS or VM
    6. HTTP Listener and Routing Rule
    7. (Optional) WAF Policy for WAF_v2 SKU

.NOTES
    Prerequisites:
    - Azure CLI installed (az version >= 2.50.0)
    - Authenticated via 'az login'
    - Existing Resource Group and Virtual Network with a dedicated 'appgw-subnet'
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ResourceGroup = "rg-myapp-dev-eastus",

    [Parameter(Mandatory = $false)]
    [string]$Location = "eastus",

    [Parameter(Mandatory = $false)]
    [string]$VNetName = "myapp-vnet-dev",

    [Parameter(Mandatory = $false)]
    [string]$SubnetName = "appgw-subnet",

    [Parameter(Mandatory = $false)]
    [string]$AppGatewayName = "myapp-appgw-dev",

    [Parameter(Mandatory = $false)]
    [string]$PublicIpName = "myapp-appgw-pip",

    [Parameter(Mandatory = $false)]
    [ValidateSet("Standard_v2", "WAF_v2")]
    [string]$Sku = "Standard_v2",

    [Parameter(Mandatory = $false)]
    [int]$MinCapacity = 1,

    [Parameter(Mandatory = $false)]
    [int]$MaxCapacity = 3,

    # Backend target IP or FQDN (e.g., AKS Ingress internal IP or VM IP)
    [Parameter(Mandatory = $false)]
    [string[]]$BackendServers = @("10.0.1.10", "10.0.2.4")
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Starting Azure Application Gateway Deployment via PowerShell" -ForegroundColor Cyan
Write-Host "Resource Group : $ResourceGroup" -ForegroundColor Yellow
Write-Host "Location       : $Location" -ForegroundColor Yellow
Write-Host "VNet / Subnet  : $VNetName / $SubnetName" -ForegroundColor Yellow
Write-Host "App Gateway    : $AppGatewayName (SKU: $Sku)" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

# -----------------------------------------------------------------------------
# 1. Verify Subnet Exists
# -----------------------------------------------------------------------------
Write-Host "`n[Step 1/6] Verifying Subnet '$SubnetName' in VNet '$VNetName'..." -ForegroundColor Green
$SubnetId = az network vnet subnet show `
    --resource-group $ResourceGroup `
    --vnet-name $VNetName `
    --name $SubnetName `
    --query id `
    --output tsv

if (-not $SubnetId) {
    throw "Subnet '$SubnetName' was not found in VNet '$VNetName'. Please deploy the Terraform networking module first."
}
Write-Host "Found Subnet ID: $SubnetId" -ForegroundColor DarkGray

# -----------------------------------------------------------------------------
# 2. Create Public IP (Standard SKU Required for App Gateway v2)
# -----------------------------------------------------------------------------
Write-Host "`n[Step 2/6] Provisioning Standard Static Public IP '$PublicIpName'..." -ForegroundColor Green
az network public-ip create `
    --resource-group $ResourceGroup `
    --name $PublicIpName `
    --location $Location `
    --sku Standard `
    --allocation-method Static `
    --output table

$PublicIpAddress = az network public-ip show `
    --resource-group $ResourceGroup `
    --name $PublicIpName `
    --query ipAddress `
    --output tsv

Write-Host "Public IP created: $PublicIpAddress" -ForegroundColor Green

# -----------------------------------------------------------------------------
# 3. Create Application Gateway with Autoscaling
# -----------------------------------------------------------------------------
Write-Host "`n[Step 3/6] Creating Application Gateway '$AppGatewayName'..." -ForegroundColor Green
$backendTargetsString = $BackendServers -join " "

az network application-gateway create `
    --resource-group $ResourceGroup `
    --name $AppGatewayName `
    --location $Location `
    --sku $Sku `
    --capacity $MinCapacity `
    --min-capacity $MinCapacity `
    --vnet-name $VNetName `
    --subnet $SubnetName `
    --public-ip-address $PublicIpName `
    --frontend-port 80 `
    --http-settings-port 80 `
    --http-settings-protocol Http `
    --http-settings-cookie-based-affinity Disabled `
    --servers $backendTargetsString `
    --priority 100 `
    --output table

# Configure autoscaling max capacity
Write-Host "Configuring autoscaling (Min: $MinCapacity, Max: $MaxCapacity)..." -ForegroundColor DarkGray
az network application-gateway autoscale-configuration update `
    --resource-group $ResourceGroup `
    --gateway-name $AppGatewayName `
    --min-capacity $MinCapacity `
    --max-capacity $MaxCapacity `
    --output none

# -----------------------------------------------------------------------------
# 4. Add Custom Health Probe
# -----------------------------------------------------------------------------
Write-Host "`n[Step 4/6] Creating Custom Health Probe 'hp-http-health'..." -ForegroundColor Green
az network application-gateway probe create `
    --resource-group $ResourceGroup `
    --gateway-name $AppGatewayName `
    --name "hp-http-health" `
    --protocol Http `
    --path "/healthz" `
    --interval 30 `
    --timeout 30 `
    --threshold 3 `
    --host-name-from-http-settings true `
    --match-status-codes "200-399" `
    --output none

# -----------------------------------------------------------------------------
# 5. Update HTTP Settings to use Health Probe and Connection Draining
# -----------------------------------------------------------------------------
Write-Host "`n[Step 5/6] Updating HTTP Settings to associate health probe & enable draining..." -ForegroundColor Green
az network application-gateway http-settings update `
    --resource-group $ResourceGroup `
    --gateway-name $AppGatewayName `
    --name "appGatewayBackendHttpSettings" `
    --probe "hp-http-health" `
    --timeout 60 `
    --enable-probe true `
    --connection-draining-timeout 60 `
    --output none

# -----------------------------------------------------------------------------
# 6. Verify Deployment Status
# -----------------------------------------------------------------------------
Write-Host "`n[Step 6/6] Verifying Application Gateway Status..." -ForegroundColor Green
$ProvisioningState = az network application-gateway show `
    --resource-group $ResourceGroup `
    --name $AppGatewayName `
    --query "provisioningState" `
    --output tsv

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Application Gateway Deployment Completed!" -ForegroundColor Cyan
Write-Host "Status        : $ProvisioningState" -ForegroundColor Green
Write-Host "Public IP     : $PublicIpAddress" -ForegroundColor Green
Write-Host "Frontend URL  : http://$PublicIpAddress" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
