
# Check if modules are installed, and install if necessary

$ErrorActionPreference = "SilentlyContinue"
$requiredModules = @("AzureAD", "MSOnline", "ExchangeOnlineManagement")

foreach ($module in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Write-Host "Installing module: $module"
        Install-Module -Name $module -Force -AllowClobber
    }
}

$Color = @{Foregroundcolor = 'Yellow'; Backgroundcolor = 'Black'}

# Connect to Azure AD
if (-not (Get-AzureADCurrentSessionInfo)) {
    Write-Host "Connecting to Azure AD....." @Color
    Connect-AzureAD
     Write-Host "Already connected to Azure AD......" @Color
} else {
    Write-Host "Already connected to Azure AD......" @Color
}

# Connect to Azure AD using the MSOnline module
if (-not (Get-MsolAccountSku)) {
    Write-Host "Connecting to Azure AD using MSOnline module....." @Color
    Connect-MsolService
    Write-Host "Already connected to Azure AD using MSOnline module......." @Color
} else {
    Write-Host "Already connected to Azure AD using MSOnline module......." @Color
}

# Connect to Exchange Online
if (-not (Get-PSSession | Select-Object -Property Name -First 1 | Where-Object { $_.Name -like "ExchangeOnline*" })) {
    Write-Host "Connecting to Exchange Online....." @Color
    Connect-ExchangeOnline
    Write-Host "Already connected to Exchange Online......." @Color
} else {
    Write-Host "Already connected to Exchange Online......." @Color
}

<# Connect to SharePoint Online
$adminUrl = "https://yourtenant-admin.sharepoint.com"
if (-not (Get-PnPContext)) {
    Write-Host "Connecting to SharePoint Online"
    Connect-PnPOnline -Url $adminUrl
} else {
    Write-Host "Already connected to SharePoint Online"
}
#>