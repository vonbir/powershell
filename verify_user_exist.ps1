# Connect to Office365 services 

$ErrorActionPreference = 'SilentlyContinue'
$requiredModules = @("AzureAD", "MSOnline", "ExchangeOnlineManagement")

foreach ($module in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module -ErrorAction SilentlyContinue)) {
        Write-Host "Installing module: $module"
        Install-Module -Name $module -Force
    }
}

# Connect to Azure AD

if (-not (Get-AzureADCurrentSessionInfo)) {
    Write-Host "Connecting to Azure AD" -ForegroundColor Yellow
    Connect-AzureAD 
} else {
    Write-Host "Already connected to Azure AD..." -ForegroundColor Yellow
}

# Connect to Azure AD using the MSOnline module
if (-not (Get-MsolAccountSku -ErrorAction SilentlyContnue)) {
    Write-Host "Connecting to Azure AD using MsOnline Module" -ForegroundColor Yellow
    Connect-MsolService
} else {
    Write-Host "Already connected to the MsOnline Module...." -ForegroundColor Yellow
}

# Connect to Exchange Online
if (-not (Get-PSSession | Select-Object -Property Name -First 1 | Where-Object { $_.Name -like "ExchangeOnline*" })) {
    Write-Host "Connecting to Exchange Online" -ForegroundColor Yellow
    Connect-ExchangeOnline
} else {
    Write-Host "Already connected to Exchange Online...." -ForegroundColor Yellow
}

Param(
    [Parameter(Mandatory)]
    [string]$upn
)

while ($upn) {
    try {
        $user = Get-MsolUser -UserPrincipalName $upn -ErrorAction Stop | Select-Object DisplayName, Title, Department, City, Office, StreetAddress, State, PhoneNumber, isLicensed, Licenses, ObjectID, userPrincipalName

        $groups = Get-AzureADUserMembership -ObjectId $user.ObjectId | Where-Object {$_.ObjectType -eq "Group"}

        $user
        $groups | Select-Object ObjectId, DisplayName, Description | Format-Table

        $retry = Read-Host "Would you like to enter another user? (Y/N)"

        if ($retry -ne "Y") {
            break
        }

        $upn = Read-Host "Please enter the user's email"
    }
    catch {
        Write-Host "Username does not exist, please try again." -ForegroundColor Yellow
        $upn = Read-Host "Please enter the user's email"
    }
}
