# Check if modules are installed, and install if necessary

$ErrorActionPreference = "SilentlyContinue"
$Color = @{Foregroundcolor = 'Yellow' }
$requiredModules = @("AzureAD", "MSOnline", "ExchangeOnlineManagement")

foreach ($module in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Write-Host "Installing module: $module"
        Install-Module -Name $module -Force -AllowClobber
    }
}

try {
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
    if (-not (Get-PSSession | Select-Object -Property Name -First 1 | Where-Object { $_.Name -eq "ExchangeOnline*" })) {
        Write-Host "Connecting to Exchange Online....." @Color
        Connect-ExchangeOnline
        Write-Host "Already connected to Exchange Online......." @Color
    } else {
        Write-Host "Already connected to Exchange Online......." @Color
    }
} catch {
    Write-Host "Something unexpected happened. Please try running it again..." -ForegroundColor Red
}
With this modification, the script should run without errors and perform the necessary module installations and connections to Azure AD and Exchange Online as intended.






