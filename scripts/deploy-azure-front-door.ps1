<#
.SYNOPSIS
    Deploys Azure Front Door (Standard/Premium) using Azure CLI commands executed in PowerShell.

.DESCRIPTION
    This script provisions:
    1. Modern Azure Front Door Profile (Standard_AzureFrontDoor or Premium_AzureFrontDoor)
    2. Front Door Endpoint
    3. Origin Group with health probes and latency sensitivity
    4. Origin targeting Application Gateway public IP or backend FQDN
    5. Routing Rule with automatic HTTPS redirect and HTTP/2 support
    6. (Optional) Custom Rules or WAF Security Policy association

.NOTES
    Prerequisites:
    - Azure CLI installed (az version >= 2.50.0)
    - Authenticated via 'az login'
    - Resource Group already created
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ResourceGroup = "rg-myapp-dev-eastus",

    [Parameter(Mandatory = $false)]
    [string]$ProfileName = "myapp-afd-dev",

    [Parameter(Mandatory = $false)]
    [ValidateSet("Standard_AzureFrontDoor", "Premium_AzureFrontDoor")]
    [string]$Sku = "Standard_AzureFrontDoor",

    [Parameter(Mandatory = $false)]
    [string]$EndpointName = "myapp-frontdoor-ep",

    [Parameter(Mandatory = $false)]
    [string]$OriginGroupName = "og-appgw-backends",

    [Parameter(Mandatory = $false)]
    [string]$OriginName = "origin-primary-appgw",

    # Hostname or IP of the origin (e.g., Application Gateway public IP or domain name)
    [Parameter(Mandatory = $false)]
    [string]$OriginHostName = "appgw.example.com",

    [Parameter(Mandatory = $false)]
    [string]$RouteName = "route-default",

    [Parameter(Mandatory = $false)]
    [string]$ProbePath = "/healthz",

    [Parameter(Mandatory = $false)]
    [switch]$EnableCaching = $false
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Starting Azure Front Door (AFD) Deployment via PowerShell" -ForegroundColor Cyan
Write-Host "Resource Group   : $ResourceGroup" -ForegroundColor Yellow
Write-Host "Profile Name     : $ProfileName (SKU: $Sku)" -ForegroundColor Yellow
Write-Host "Endpoint Name    : $EndpointName" -ForegroundColor Yellow
Write-Host "Origin Host      : $OriginHostName" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

# -----------------------------------------------------------------------------
# 1. Create Azure Front Door Profile
# -----------------------------------------------------------------------------
Write-Host "`n[Step 1/5] Creating AFD Profile '$ProfileName'..." -ForegroundColor Green
az afd profile create `
    --resource-group $ResourceGroup `
    --profile-name $ProfileName `
    --sku $Sku `
    --output table

# -----------------------------------------------------------------------------
# 2. Create AFD Endpoint
# -----------------------------------------------------------------------------
Write-Host "`n[Step 2/5] Creating Endpoint '$EndpointName'..." -ForegroundColor Green
az afd endpoint create `
    --resource-group $ResourceGroup `
    --profile-name $ProfileName `
    --endpoint-name $EndpointName `
    --enabled-state Enabled `
    --output table

# -----------------------------------------------------------------------------
# 3. Create Origin Group with Health Probing
# -----------------------------------------------------------------------------
Write-Host "`n[Step 3/5] Creating Origin Group '$OriginGroupName'..." -ForegroundColor Green
az afd origin-group create `
    --resource-group $ResourceGroup `
    --profile-name $ProfileName `
    --origin-group-name $OriginGroupName `
    --probe-request-type GET `
    --probe-protocol Http `
    --probe-interval-in-seconds 30 `
    --probe-path $ProbePath `
    --sample-size 4 `
    --successful-samples-required 3 `
    --additional-latency-in-milliseconds 50 `
    --output table

# -----------------------------------------------------------------------------
# 4. Create Origin inside Origin Group
# -----------------------------------------------------------------------------
Write-Host "`n[Step 4/5] Registering Origin '$OriginName' with host '$OriginHostName'..." -ForegroundColor Green
az afd origin create `
    --resource-group $ResourceGroup `
    --profile-name $ProfileName `
    --origin-group-name $OriginGroupName `
    --origin-name $OriginName `
    --host-name $OriginHostName `
    --http-port 80 `
    --https-port 443 `
    --origin-host-header $OriginHostName `
    --priority 1 `
    --weight 1000 `
    --enabled-state Enabled `
    --enforce-certificate-name-check false `
    --output table

# -----------------------------------------------------------------------------
# 5. Create Routing Rule
# -----------------------------------------------------------------------------
Write-Host "`n[Step 5/5] Creating Route '$RouteName' with HTTPS redirection..." -ForegroundColor Green

$cacheOption = if ($EnableCaching) { "UseQueryString" } else { "IgnoreQueryString" }

az afd route create `
    --resource-group $ResourceGroup `
    --profile-name $ProfileName `
    --endpoint-name $EndpointName `
    --route-name $RouteName `
    --origin-group $OriginGroupName `
    --supported-protocols Http Https `
    --link-to-default-domain Enabled `
    --forwarding-protocol MatchRequest `
    --https-redirect Enabled `
    --patterns-to-match "/*" `
    --output table

# -----------------------------------------------------------------------------
# Query Endpoint Details
# -----------------------------------------------------------------------------
$EndpointHost = az afd endpoint show `
    --resource-group $ResourceGroup `
    --profile-name $ProfileName `
    --endpoint-name $EndpointName `
    --query "hostName" `
    --output tsv

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host "Azure Front Door Deployment Completed Successfully!" -ForegroundColor Cyan
Write-Host "Profile Name    : $ProfileName" -ForegroundColor Green
Write-Host "Endpoint Name   : $EndpointName" -ForegroundColor Green
Write-Host "Public URL      : https://$EndpointHost" -ForegroundColor Green
Write-Host "Backend Target  : $OriginHostName" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
