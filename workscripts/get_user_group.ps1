
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
    Write-Host "Already connected to Azure AD...." -ForegroundColor Yellow
}

# Connect to Azure AD using the MSOnline module
if (-not (Get-MsolAccountSku)) {
    Write-Host "Connecting to Azure AD using MsOnline Module" -ForegroundColor Yellow
    Connect-MsolService
} else {
    Write-Host "Already connected to the MSOnline Module...." -ForegroundColor Yellow
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

# pulls both the AD groups and AAD groups

$user = get-azureaduser -ObjectId $upn

$adGroup = Get-ADPrincipalGroupMembership -Identity $user.UserPrincipalName


$aadGroup = Get-AzureADUserMembership -ObjectId $User.ObjectId

$Results = for ( $i = 0; $i -lt $max; $i++) {
    Write-Verbose "$adGroup"
    [PSCustomObject]@{
        AD_Groups = $adGroup[$i]
        #AAD_Groups = $lastName[$i]

    }
}


$results = foreach ($group in $adGroup) {
    [PSCustomObject]@{
        ADGroup  = $group.Name -join ', '
        AADGroup = ''
    }
}

foreach ($aadGroupItem in $aadGroup) {
    $results += [PSCustomObject]@{

        AADGroup = $aadGroupItem.DisplayName -join ', '
    }
}

$results | Where-Object { $_.ADGroup -ne '' -or $_.AADGroup -ne '' }
