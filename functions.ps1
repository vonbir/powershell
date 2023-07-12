
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


Function Create-ADComputer {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [ValidateSet("GGNB", "FGNB", "HTNB", "THNB", "GBSNB")]
        [string]$CompanyGroup
    )

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
    # asks for the on-prem AD admin credentials to verify and create the computer object
    Write-Host
    if (-not ($adminuser)){
    [string]$adminuser = Read-Host "Please enter your on-prem AD username to verify" 
    $adminpass = Read-Host "Please enter your on-prem AD password" -AsSecureString 
    $Cred = New-Object System.Management.Automation.PSCredential $adminuser,$adminpass
    }
    
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
}
