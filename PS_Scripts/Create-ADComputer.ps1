Function Create-ADComputer {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [ValidateSet("GGNB", "FGNB", "HTNB", "THNB", "GBSNB", "HCNB", "GGDT", "FGDT", "HTDT", "THDT", "GBSDT", "HCDT")]
        [string]$CompanyGroup
    )

    # Check if Active Directory module is installed
    if (-not (Get-Module -Name ActiveDirectory -ListAvailable)) {
        Write-Host "Active Directory module not found. Installing the module..."
        Install-Module -Name RSAT-AD-PowerShell -Scope CurrentUser -Force
    }

    # Import Active Directory module
    Import-Module -Name ActiveDirectory

    # domain admin credentials

    if (-not ($adminuser)) {
        [string]$adminuser = Read-Host "Please enter your on-prem AD username (GREATGULF\username)"
        $adminpass = Read-Host "Please enter your on-prem AD password" -AsSecureString
        $Cred = New-Object System.Management.Automation.PSCredential $adminuser, $adminpass
    }
    Write-Host
    Write-Host "You are currently logged in as: " -NoNewline; Write-Host "$adminuser" -ForegroundColor Yellow
    Write-Host

    $names = Get-ADComputer -Filter * -SearchBase "OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz" |
    Where-Object { $_.Name -match "^$CompanyGroup\d+$" } |
    Select-Object -ExpandProperty Name

    [int[]]$num = $names -replace '\D+'

    if ($CompanyGroup -eq "HTNB" -or $CompanyGroup -eq "HTDT") {
        $latestNumber = ($num | Where-Object { $_ -ne "1463" -and $_ -ne "225" } | Sort-Object -Descending | Select-Object -First 1) -as [int]
        $nextNumber = $latestNumber + 1
        $nextComputerName = "{0}0{1:D3}" -f $CompanyGroup, $nextNumber
    } else {
        $latestNumber = ($num | Sort-Object -Descending | Select-Object -First 1) -as [int]
        $nextNumber = $latestNumber + 1
        $nextComputerName = "{0}{1:D4}" -f $CompanyGroup, $nextNumber
    }

    Write-Host
    Write-Host "Next available computer name:" -ForegroundColor Cyan -NoNewline; Write-Host " $nextComputerName" -ForegroundColor Yellow;
    Write-Host

    $createComputer = Read-Host "Do you want to create this computer object? (Y/N)"

    if ($createComputer -eq "Y") {
        Write-Host
        $displayuser = Read-Host "Who will this computer belong to? (username for description)"

        if ($CompanyGroup -like "TH*") {
            $computerPath = "OU=Computers,OU=TuckerHiRise,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
        } elseif ($CompanyGroup -like "GG*") {
            $computerPath = "OU=Computers,OU=GreatGulf,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
        } elseif ($CompanyGroup -like "HT*") {
            $computerPath = "OU=Computers,OU=BrockportHS,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
        } elseif ($CompanyGroup -like "GBS*") {
            $computerPath = "OU=Computers,OU=GreatBuilderSolutions,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
        } elseif ($CompanyGroup -like "HC*") {
            $computerPath = "OU=Computers,OU=HomeCAD,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
        } elseif ($CompanyGroup -like "FG*") {
            $computerPath = "OU=Computers,OU=FirstGulf,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
        } else {
            Write-Host
            Write-Host "Computer object creation cancelled...." -ForegroundColor Red
            Write-Host
        }
        $computerProperties = @{
            Name           = $nextComputerName
            SamAccountName = $nextComputerName
            Path           = $computerPath
            Enabled        = $true
            Description    = $displayuser
        }
        New-ADComputer @computerProperties -PassThru -Credential $Cred
        Write-Host "Computer object created successfully!!!" -ForegroundColor Yellow
    } else {
        Write-Host
        Write-Host "Computer object creation has been cancelled..." -ForegroundColor Red
        Write-Host
    }
}