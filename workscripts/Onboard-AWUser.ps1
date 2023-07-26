Function Onboard-AWUser {
    [CmdletBinding()]
    Param()

    # Check if modules are installed and install if necessary
    $requiredModules = @("AzureAD", "MSOnline", "ExchangeOnlineManagement")
    $ErrorActionPreference = 'SilentlyContinue'

    foreach ($module in $requiredModules) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            Write-Host "Installing module: $module"
            Install-Module -Name $module -Force -AllowClobber
        }
    }

    # Connect to Azure AD
    $TestAzureADConnection = Get-AzureADCurrentSessionInfo
    if (-not ($TestAzureADConnection)) {
        Write-Host "Connecting to Azure AD..." -ForegroundColor DarkYellow
        Connect-AzureAD
        Write-Host "Successfully connected to AzureAD..." -ForegroundColor Yellow
    } else {
        Write-Host "Successfully connected to Azure AD..." -ForegroundColor Yellow
    }

    # Connect to Azure AD using the MSOnline module
    if (-not (Get-MsolAccountSku)) {
        Write-Host "Connecting to the MSOnline module..."
        Connect-MsolService
        Write-Host "Successfully connected to the MSOnline module." -ForegroundColor Yellow
    } else {
        Write-Host "Successfully connected to the MSOnline module." -ForegroundColor Yellow
    }

    # Connect to Exchange Online
    if (-not (Get-PSSession | Select-Object -Property Name -First 1 | Where-Object { $_.Name -eq "ExchangeOnline*" })) {
        Write-Host "Connecting to Exchange Online..."
        Connect-ExchangeOnline
        Write-Host "Successfully connected to Exchange Online." -ForegroundColor Yellow
    } else {
        Write-Host "Successfully connected to Exchange Online." -ForegroundColor Yellow
    }
}