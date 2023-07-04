
# Check if modules are installed, and install if necessary
$requiredModules = @("AzureAD", "MSOnline", "ExchangeOnlineManagement")

foreach ($module in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Write-Host "Installing module: $module"
        Install-Module -Name $module -Force -AllowClobber
    }
}

# Connect to Azure AD
if (-not (Get-AzureADCurrentSessionInfo)) {
    Write-Host "Connecting to Azure AD"
    Connect-AzureAD
} else {
    Write-Host "Already connected to Azure AD"
}

# Connect to Azure AD using the MSOnline module
if (-not (Get-MsolAccountSku)) {
    Write-Host "Connecting to Azure AD using MSOnline module"
    Connect-MsolService
} else {
    Write-Host "Already connected to Azure AD using MSOnline module"
}

# Connect to Exchange Online
if (-not (Get-PSSession | Select-Object -Property Name -First 1 | Where-Object { $_.Name -like "ExchangeOnline*" })) {
    Write-Host "Connecting to Exchange Online"
    Connect-ExchangeOnline
} else {
    Write-Host "Already connected to Exchange Online"
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