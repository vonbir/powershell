
Function Get-ADG {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string]$upn
    )
    Try {
        $adUser = Get-AzureADUser -ObjectId $upn
        $adGroup = Get-ADPrincipalGroupMembership -Identity $adUser.MailNickName
        $adGroup | Select-Object Name
    } Catch {
        Write-Host $Error[0] -ForegroundColor Red
        Write-Host "Something went wrong, please try running the function again......." -ForegroundColor Yellow
    }
}

Function Get-AADG {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string]$upn
    )
    Try {
        $aadUser = Get-AzureADUser -SearchString $upn
        $aadGroup = Get-AzureADUserMembership -ObjectId $aadUser.ObjectId
        $aadGroup | Select-Object DisplayName, ObjectType, ObjectID
    } Catch {
        Write-Host $Error[0] -ForegroundColor Red
        Write-Host "Something went wrong, please try running the function again......." -ForegroundColor Yellow
    }
}

Function Get-MailboxLogonTime {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string]$email
    )
    Try {
        $aadUser = Get-AzureADUser -ObjectId $email
        $stats = Get-MailboxStatistics -Identity $aadUser.MailNickName
        $stats | Select-Object DisplayName, LastLogonTime, MailboxTypeDetail
    } Catch {
        Write-Host $Error[0] -ForegroundColor Red
        Write-Host "Something went wrong, please try running the function again......." -ForegroundColor Yellow
    }
}

Function Verify-UserExist {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string]$UserPrincipalName
    )
    try {
        $user = Get-MsolUser -SearchString $UserPrincipalName | Select-Object DisplayName, Title, Department, City, Office, StreetAddress, State, PhoneNumber, isLicensed, Licenses, ObjectID, userPrincipalName, UserType, BlockCredential

        $groups = Get-AzureADUserMembership -ObjectId $user.ObjectId | Where-Object { $_.ObjectType -eq "Group" } | Select-Object DisplayName, Description

        Write-Host
        Write-Host "USER DETAILS:" -ForegroundColor Yellow -BackgroundColor DarkRed
        Write-Host
        $user | Out-String -Width 4096 | ForEach-Object { $_.Trim() }
        Write-Host
        Write-Host "THIS USER BELONGS TO THESE AZURE GROUPS:" -ForegroundColor Yellow -BackgroundColor DarkRed
        $groups | Format-Table -AutoSize| Out-String -Width 4096
    } 
    catch {
        Write-Host "Username does not exist, please try again." -ForegroundColor Yellow
    }
}

Function Verify-UserTerminated {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [string]$UserPrincipalName
    )

    Try {
        $user = Get-MsolUser -SearchString $UserPrincipalName | ForEach-Object {
            [pscustomobject]@{
                blockedCredential = $_.BlockCredential
                objectID          = $_.ObjectID
                UserPrincipalName = $_.UserPrincipalName
            }
        }

        $azureADUser = Get-AzureADUser -ObjectId $user.ObjectId | ForEach-Object {
            [pscustomobject]@{
                AccountEnabled    = $_.AccountEnabled
                jobTitle          = $_.jobTitle
                displayName       = $_.displayName
                StreetAddress     = $_.StreetAddress
                State             = $_.State
                TelephoneNumber   = $_.TelephoneNumber
                userPrincipalName = $_.userPrincipalName
                PostalCode        = $_.PostalCode
                City              = $_.City
                Department        = $_.Department
                CompanyName       = $_.CompanyName
            }
        }

        $groups = Get-AzureADUserMembership -ObjectId $user.ObjectId |
            Where-Object { $_.ObjectType -eq "Group" } | ForEach-Object {
                [pscustomobject]@{
                    ObjectID    = $_.ObjectID
                    DisplayName = $_.DisplayName
                    Description = $_.Description
                }
            }

        $mailbox = Get-Mailbox -Identity $UserPrincipalName | ForEach-Object {
            [pscustomobject]@{
                RecipientTypeDetails      = $_.RecipientTypeDetails
                AccountDisabled           = $_.AccountDisabled
                userPrincipalName         = $_.userPrincipalName
                msexchHideFromAddressBook = $_.HiddenFromAddressListsEnabled
                TerminationDate           = $_.customAttribute15
                ForwardingSmtpAddress     = $_.ForwardingSmtpAddress
                EmailForwardingStatus     = $_.DeliverToMailboxAndForward
            }
        }

        # Create a custom object with the desired properties
        $results = [PSCustomObject]@{
            userPrincipalName         = $user.userPrincipalName
            AccountEnabled            = $AzureADUser.AccountEnabled
            RecipientTypeDetails      = $mailbox.RecipientTypeDetails
            jobTitle                  = $azureADUser.jobTitle
            StreetAddress             = $azureADUser.StreetAddress
            State                     = $azureADUser.State
            TelephoneNumber           = $azureADUser.TelephoneNumber
            PostalCode                = $AzureADUser.PostalCode
            City                      = $AzureADUser.City
            Department                = $AzureADUser.Department
            CompanyName               = $AzureADUser.CompanyName
            o365_groups               = $groups.DisplayName
            msexchHideFromAddressBook = $mailbox.msexchHideFromAddressBook
            blockedCredential         = $user.blockedCredential
            EmailForwardingStatus     = $mailbox.EmailForwardingStatus
            ForwardingSmtpAddress     = $mailbox.ForwardingSmtpAddress
            TerminationDate           = $mailbox.TerminationDate
        }
        $results | Format-List *
    } Catch {
        Write-Host "The user does not exist. Please try again later.." -ForegroundColor Red -BackgroundColor Yellow
    }
}

Function Create-NewUser {
    [CmdletBinding()]
    Param(
    )

# Check if Active Directory module is installed
if (-not (Get-Module -Name ActiveDirectory -ListAvailable)) {
    Write-Host "Active Directory module not found. Installing the module..."
    Install-Module -Name RSAT-AD-PowerShell -Scope CurrentUser -Force
}

# Import Active Directory module
Import-Module -Name ActiveDirectory

# domain admin credentials

if (-not ($adminuser)){
[string]$adminuser = Read-Host "Please enter your on-prem AD username (\GREATGULF\string)" 
$adminpass = Read-Host "Please enter your on-prem AD password" -AsSecureString 
$Cred = New-Object System.Management.Automation.PSCredential $adminuser,$adminpass
}
Write-Host
Write-Host "You are currently logged in as: " -NoNewline;Write-Host "$adminuser" -ForegroundColor Yellow
Write-Host

# Prompt for user details

Try {
$splatADUser =  [ordered]@{
    GivenName = Read-Host "Enter the first name of the user to create"
	Surname = Read-Host "Enter the last name"
	AccountPassword = Read-Host "Enter the password" -AsSecureString
	Description = Read-Host "Enter the user's Job Title"
	Department = Read-Host "Enter the user's Department"
	#Manager = Read-Host "Enter the user's Reporting Manager"
	Enabled = $true
}

$SamAccountName = $($splatADUser.GivenName) + "." + $($splatADUser.Surname)
$Name = $($splatADUser.GivenName) + " " + $($splatADUser.Surname)

[string]$containerInput = Read-Host ("Enter the container division for this user (GG,FG,THR,GBS,HT,DD)")
        $containerinput = $containerInput.ToUpper()
        $extensionAttribute1 = $containerInput
[string]$extensionAttribute2 = Read-Host "Enter extension attribute 2 value (License Type, E3/F3)"
[string]$extensionAttribute10 = Read-Host "Enter extension attribute 10 value (Hiring date, yyyy/MM/dd)"
[string]$extensionAttribute14 = Read-Host "Enter extension attribute 14 value (AADSyncTrue or not?)"

# Set container DN based on user's input

if ($containerInput -match "GG") {
    $containerDN = "OU=Users,OU=GreatGulf,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
    $useremail = "$SamAccountName@greatgulf.com"
}
        elseif ($containerInput -eq "FG") {
            $containerDN = "OU=Users,OU=FirstGulf,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
            $useremail = "$($firstName.Substring(0,1))$lastName@firstgulf.com"
        }
        elseif ($containerInput  -eq "THR") {
            $containerDN = "OU=Users,OU=TuckerHiRise,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
            $useremail = "$SamAccountName@tuckerhirise.com"
        }
        elseif ($containerInput -eq "GBS") {
            $containerDN = "OU=Users,OU=GreatBuilderSolutions,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
            $useremail = "$SamAccountName@greatbuildersolutions.com"
        }
        elseif ($containerInput -eq "HT") {
            $containerDN = "OU=Users,OU=BrockportHS,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
            $useremail = "$SamAccountName@hometechnology.com"
        }
        elseif ($containerInput -eq "DD") {
            $containerDN = "OU=Users,OU=HomeCAD,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
            $useremail = "$SamAccountName@draftdesign.ca"
        }

# Create user object
New-ADUser $SamAccountName @splatADUser -Path $containerDN -Credential $Cred -EmailAddress $useremail -UserPrincipalName $useremail -SamAccountName $SamAccountName -DisplayName $Name

$user = get-aduser -Identity $SamAccountName -Properties *

# Set extension attributes
if ($extensionAttribute14 -eq "AADSyncTrue"){
Set-ADUser -Identity $user.DistinguishedName -Add @{extensionAttribute1 = $extensionAttribute1; extensionAttribute2 = $extensionAttribute2; extensionAttribute10 = $extensionAttribute10; extensionAttribute14 = $extensionAttribute14} -Credential $Cred -Title $splatADUser.Description -Department $splatADUser.Department `
-StreetAddress "351 King Street East, 13th Floor, Suite 1300" -City "Toronto" -PostalCode "M5A 0L6" -Country CA
}
else {
Set-ADUser -Identity $user.DistinguishedName -Add @{extensionAttribute1 = $extensionAttribute1; extensionAttribute10 = $extensionAttribute10; extensionAttribute14 = $extensionAttribute14} -Clear extensionAttribute2 -Credential $cred -Title $splatADUser.Description -Department $splatADUser.Department `
-StreetAddress "351 King Street East, 13th Floor, Suite 1300" -City "Toronto" -PostalCode "M5A 0L6" -Country CA
}

# Output the created user details
Write-Host
Write-Host -ForegroundColor Yellow "The user has been created successfully!"
Write-Host
Write-Host "Username: " -NoNewline;Write-Host -ForegroundColor Yellow "Username: $SamAccountName"
Write-Host "ExtensionAttribute1: " -NoNewline;Write-Host -ForegroundColor Yellow "$extensionAttribute1"
Write-Host "ExtensionAttribute2: " -NoNewline;Write-Host -ForegroundColor Yellow "$extensionAttribute2"
Write-Host "ExtensionAttribute10: " -NoNewline;Write-Host -ForegroundColor Yellow "$extensionAttribute10"
Write-Host "ExtensionAttribute14: " -NoNewline;Write-Host -ForegroundColor Yellow "$extensionAttribute14"
Write-Host
}
Catch {
 Write-Host
 Write-Host "[ERROR]`t Oops, something went wrong: $($_.Exception.Message)`r`n" -ForegroundColor Red
 Write-Host
 }
 }

Function Create-ADComputer {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [ValidateSet("GGNB", "FGNB", "HTNB", "THNB", "GBSNB", "HCNB")]
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

    if (-not ($adminuser)){
    [string]$adminuser = Read-Host "Please enter your on-prem AD username (\GREATGULF\string)" 
    $adminpass = Read-Host "Please enter your on-prem AD password" -AsSecureString 
    $Cred = New-Object System.Management.Automation.PSCredential $adminuser,$adminpass
    }
    Write-Host
    Write-Host "You are currently logged in as: " -NoNewline;Write-Host "$adminuser" -ForegroundColor Yellow
    Write-Host

    $names = Get-ADComputer -Filter * -SearchBase "OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz" |
        Where-Object { $_.Name -match "^$CompanyGroup\d+$" } |
        Select-Object -ExpandProperty Name

    [int[]]$num = $names -replace '\D+'

    if ($CompanyGroup -eq "HTNB"){
    $latestNumber = ($num | Where-Object { $_ -ne "1463" -and $_ -ne "225" } | Sort-Object -Descending | Select-Object -First 1) -as [int]
    $nextNumber = $latestNumber + 1
    $nextComputerName = "$CompanyGroup{00:D3}" -f $nextNumber
    }
    else{
    $latestNumber = ($num | Sort-Object -Descending | Select-Object -First 1) -as [int]
    $nextNumber = $latestNumber + 1
    $nextComputerName = "$CompanyGroup{0:D4}" -f $nextNumber
    }
    Write-Host
    Write-Host "Next available computer name:" -ForegroundColor Cyan -NoNewline; Write-Host " $nextComputerName" -ForegroundColor Yellow;
    Write-Host

    $createComputer = Read-Host "Do you want to create this computer object? (Y/N)"

    if ($createComputer -eq "Y"){
 
    Write-Host
    $displayuser = Read-Host "Who will this computer belong to? (username for description)"

    if ($CompanyGroup -eq "THNB") {
        $computerPath = "OU=Computers,OU=TuckerHiRise,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
        }
        elseif ($CompanyGroup -eq "GGNB"){
        $computerPath = "OU=Computers,OU=GreatGulf,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
        }
        elseif ($CompanyGroup -eq "HTNB"){
        $computerPath = "OU=Computers,OU=BrockportHS,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
        }
        elseif ($CompanyGroup -eq "GBSNB"){
        $computerPath = "OU=Computers,OU=GreatBuilderSolutions,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
        }
        elseif ($CompanyGroup -eq "HCNB"){
        $computerPath = "OU=Computers,OU=HomeCAD,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
        }
  else {
        Write-Host
        Write-Host "Computer object creation cancelled...." -ForegroundColor Red
        Write-Host
        }
  $computerProperties = @{
            Name = $nextComputerName
            SamAccountName = $nextComputerName
            Path = $computerPath
            Enabled = $true
            Description = $displayuser
        }
        New-ADComputer @computerProperties -PassThru -Credential $Cred
        Write-Host "Computer object created successfully!!!" -ForegroundColor Yellow
    }
else {
Write-Host
Write-Host "Computer object creation has been cancelled..." -ForegroundColor Red
Write-Host
}
}
