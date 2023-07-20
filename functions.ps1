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
} ## gets all the AD groups of a user
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
} ## gets all the AzureAD groups of a user
Function Set-AADG {
    <#
        .DESCRIPTION
        This function removes or adds a user to the MFA Exclude security group for efficiency purposes.

        i.e Set-MFAExclude -UserPrincipalName brylle.purificacion -Add
    #>

    [CmdletBinding()]
    param (
        [switch]$Remove,
        [switch]$Add,
        [Parameter(Mandatory)]
        [string]$UserPrincipalName,
        [string]$GroupName
    )

    # Check if Exchange Online module is installed, and install if necessary
    if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
        Write-Host "Installing module: ExchangeOnlineManagement"
        Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber
    }

    # Connect to Exchange Online if not already connected
    if ((Get-ConnectionInformation).tokenStatus -ne 'Active') {
        Write-Host
        Write-Host 'Connecting to Exchange Online....' -ForegroundColor Yellow
        Write-Host
        Connect-ExchangeOnline -ShowBanner:$false
        Write-Host 'Successfully logged in...' -ForegroundColor Yellow
        Write-Host '.............................'
    } else {
        Write-Host
        Write-Host "Something unexpected happened. Please try again later."
        Write-Host
    }

    # Retrieve the MFA Exclude group
    $groupObject = Get-AzureADGroup -SearchString $GroupName
    if (-not $groupObject) {
        Write-Host
        Write-Host "The group has not been found. Please try running it again.." -ForegroundColor Red
        Write-Host
        return
    }

    # Retrieve the user
    $userObject = Get-AzureADUser -SearchString $UserPrincipalName
    if (-not $userObject) {
        Write-Host
        Write-Host "The user was not found. Please try running it again.." -ForegroundColor Red
        Write-Host
        return
    }

    # Remove user from the MFA Exclude group
    if ($Remove) {
        try {
            Remove-AzureADGroupMember -ObjectId $groupObject.ObjectId -MemberId $userObject.ObjectId -ErrorAction Stop
            Write-Host
            Write-Host "The user: " -NoNewline
            Write-Host "$($userObject.UserPrincipalName) " -NoNewline -ForegroundColor Yellow
            Write-Host "has been " -NoNewline
            Write-Host "REMOVED " -ForegroundColor DarkGreen -NoNewline
            Write-Host "from the security group: $GroupName"
            Write-Host
        } catch {
            Write-Host
            Write-Host "Failed to remove the user from the security group: $GroupName" -ForegroundColor Red
            Write-Host "$($_.Exception.Message)" -ForegroundColor Red
            Write-Host
            Write-Host "Exiting script..." -ForegroundColor Red
            Write-Host
        }
    }

    # Add user to the MFA Exclude group
    if ($Add) {
        try {
            Add-AzureADGroupMember -ObjectId $groupObject.ObjectId -RefObjectId $userObject.ObjectId -ErrorAction Stop
            Write-Host
            Write-Host "The user: " -NoNewline
            Write-Host "$($userObject.UserPrincipalName) " -NoNewline -ForegroundColor Yellow
            Write-Host "has been " -NoNewline
            Write-Host "ADDED " -ForegroundColor Green -NoNewline
            Write-Host "to the security group: $GroupName"
            Write-Host
        } catch {
            Write-Host
            Write-Host "Failed to add the user from the security group: $GroupName" -ForegroundColor Red
            Write-Host "$($_.Exception.Message)" -ForegroundColor Red
            Write-Host
            Write-Host "Exiting script..." -ForegroundColor Red
            Write-Host
        }
    }
}
## this is to add a user to a security group under azure
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
} ## gets the lastlogontime for a mailbox
Function Verify-UserExist {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string]$UserPrincipalName
    )
    try {
        $user = Get-MsolUser -SearchString $UserPrincipalName | Select-Object DisplayName, Title, Department, City, Office, StreetAddress, State, PhoneNumber, isLicensed, Licenses, ObjectID, userPrincipalName, UserType, BlockCredential, whenCreated

        $groups = Get-AzureADUserMembership -ObjectId $user.ObjectId | Where-Object { $_.ObjectType -eq "Group" } | Select-Object DisplayName, Description

        Write-Host
        Write-Host "*USER DETAILS:" -ForegroundColor Yellow
        Write-Host
        $user | Out-String -Width 4096 | ForEach-Object { $_.Trim() }
        Write-Host
        Write-Host "*THIS USER BELONGS TO THESE AZURE GROUPS:" -ForegroundColor Yellow
        $groups | Format-Table -AutoSize | Out-String -Width 4096
    } catch {
        Write-Host "Username does not exist, please try again." -ForegroundColor Yellow
    }
} ## verify if a user exists under o365/ad
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
} ## verify if a user has been terminated
Function Onboard-ADUser {
    [CmdletBinding()]
    Param()

    # Check if Active Directory module is installed
    if (-not (Get-Module -Name ActiveDirectory -ListAvailable)) {
        Write-Host "Active Directory module not found. Installing the module..."
        Install-Module -Name RSAT-AD-PowerShell -Scope CurrentUser -Force
    }

    # Import Active Directory module
    Import-Module -Name ActiveDirectory

    # domain admin credentials

    if (-not ($adminuser)) {
        $adminuser = Read-Host "Please enter your on-prem AD username (GREATGULF\username)"
        $adminpass = Read-Host "Please enter your on-prem AD password" -AsSecureString
        $Cred = New-Object System.Management.Automation.PSCredential $adminuser, $adminpass
    }
    Write-Host
    Write-Host "You are currently logged in as: " -NoNewline; Write-Host "$adminuser" -ForegroundColor Yellow
    Write-Host

    # Prompt for user details

    Try {
        $splatADUser = [ordered]@{
            GivenName       = Read-Host "Enter the first name of the user to create"
            Surname         = Read-Host "Enter the last name"
            AccountPassword = Read-Host "Enter the password" -AsSecureString
            Description     = Read-Host "Enter the user's Job Title"
            Department      = Read-Host "Enter the user's Department"
            #Manager = Read-Host "Enter the user's Reporting Manager"
            Enabled         = $true
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
        } elseif ($containerInput -eq "FG") {
            $containerDN = "OU=Users,OU=FirstGulf,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
            $useremail = "$($firstName.Substring(0,1))$lastName@firstgulf.com"
        } elseif ($containerInput -eq "THR") {
            $containerDN = "OU=Users,OU=TuckerHiRise,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
            $useremail = "$SamAccountName@tuckerhirise.com"
        } elseif ($containerInput -eq "GBS") {
            $containerDN = "OU=Users,OU=GreatBuilderSolutions,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
            $useremail = "$SamAccountName@greatbuildersolutions.com"
        } elseif ($containerInput -eq "HT") {
            $containerDN = "OU=Users,OU=BrockportHS,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
            $useremail = "$SamAccountName@hometechnology.com"
        } elseif ($containerInput -eq "DD") {
            $containerDN = "OU=Users,OU=HomeCAD,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
            $useremail = "$SamAccountName@draftdesign.ca"
        }

        # Create user object
        New-ADUser $SamAccountName @splatADUser -Path $containerDN -Credential $Cred -EmailAddress $useremail -UserPrincipalName $useremail -SamAccountName $SamAccountName -DisplayName $Name -Name $Name

        $user = Get-ADUser -Identity $SamAccountName -Properties *

        # Set extension attributes
        if ($extensionAttribute14 -eq "AADSyncTrue") {
            Set-ADUser -Identity $user.DistinguishedName -Add @{extensionAttribute1 = $extensionAttribute1; extensionAttribute2 = $extensionAttribute2; extensionAttribute10 = $extensionAttribute10; extensionAttribute14 = $extensionAttribute14 } -Credential $Cred -Title $splatADUser.Description -Department $splatADUser.Department `
                -StreetAddress "351 King Street East, 13th Floor, Suite 1300" -City "Toronto" -PostalCode "M5A 0L6" -Country CA
        } else {
            Set-ADUser -Identity $user.DistinguishedName -Add @{extensionAttribute1 = $extensionAttribute1; extensionAttribute10 = $extensionAttribute10; extensionAttribute14 = $extensionAttribute14 } -Clear extensionAttribute2 -Credential $cred -Title $splatADUser.Description -Department $splatADUser.Department `
                -StreetAddress "351 King Street East, 13th Floor, Suite 1300" -City "Toronto" -PostalCode "M5A 0L6" -Country CA
        }

        # Output the created user details
        Write-Host
        Write-Host -ForegroundColor Yellow "The user has been created successfully!"
        Write-Host
        Write-Host "Username: " -NoNewline; Write-Host -ForegroundColor Yellow "Username: $SamAccountName"
        Write-Host "ExtensionAttribute1: " -NoNewline; Write-Host -ForegroundColor Yellow "$extensionAttribute1"
        Write-Host "ExtensionAttribute2: " -NoNewline; Write-Host -ForegroundColor Yellow "$extensionAttribute2"
        Write-Host "ExtensionAttribute10: " -NoNewline; Write-Host -ForegroundColor Yellow "$extensionAttribute10"
        Write-Host "ExtensionAttribute14: " -NoNewline; Write-Host -ForegroundColor Yellow "$extensionAttribute14"
        Write-Host
    } Catch {
        Write-Host
        Write-Host "[ERROR]`t Oops, something went wrong: $($_.Exception.Message)`r`n" -ForegroundColor Red
        Write-Host
    }
} ## creates an ad user on-prem with specified attributes
Function Offboard-ADUser {
    [CmdletBinding()]
    Param()

    # Check if Active Directory module is installed
    if (-not (Get-Module -Name ActiveDirectory -ListAvailable)) {
        Write-Host "Active Directory module not found. Installing the module..."
        Install-Module -Name RSAT-AD-PowerShell -Scope CurrentUser -Force
    }

    # Import Active Directory module
    Import-Module -Name ActiveDirectory

    # domain admin credentials
    if (-not ($adminuser)) {
        $adminuser = Read-Host "Please enter your on-prem AD username (GREATGULF\username)"
        $adminpass = Read-Host "Please enter your on-prem AD password" -AsSecureString
        $Cred = New-Object System.Management.Automation.PSCredential $adminuser, $adminpass
    }
    Write-Host
    Write-Host "You are currently logged in as: " -NoNewline; Write-Host "$adminuser" -ForegroundColor Yellow
    Write-Host

    # Ask for user to disable
    [string]$samname = Read-Host "Please enter the username of the user to disable"

    # Verify user exists, error handle
    $User = $(try { Get-ADUser $samname -Properties * } catch { $null })

    # current date
    $date = Get-Date -Format yyyy/MM/dd

    try {
        if ($null -ne $User) {

            # disables the AD account
            Disable-ADAccount -Identity $samname -Credential $Cred
            Write-Host "--------------------------------------"
            Write-Host "Successfully disabled the user: $samname" -ForegroundColor Green

            # removes all AD groups
            Get-ADUser -Identity $samname -Properties MemberOf | ForEach-Object {

                $_.MemberOf | Remove-ADGroupMember -Credential $Cred -Members $_.DistinguishedName -Confirm:$false
                Write-Host "Successfully removed the user $samname from all the Active Directory Groups" -ForegroundColor Green
            }

            # puts the current termination date
            Set-ADUser -Identity $samname -Replace @{extensionAttribute15 = "$date" } -Clear extensionAttribute2 -Credential $Cred
            Write-Host "The termination date has been set to: $date" -ForegroundColor Green
            Write-Host "The license has also been removed." -ForegroundColor Green

            # hides the user from the global adddress book
            Set-ADUser -Identity $samname -Add @{msExchHideFromAddressLists = $true } -Credential $Cred
            Write-Host "The msExchHideFromAddressLists attribute has been set to: $($samname.msExchHideFromAddressLists)" -ForegroundColor Green

            # initiate sign-out of all office 365 sessions by revoking the refresh tokens issue to applications for a use
            Get-AzureADUser -SearchString $samname | revoke-azureaduserallrefreshtoken
            Write-Host "Successfully initiated sign-out of all o365 sessions for this user.." -ForegroundColor Green

            # blocks sign-in from this o365 account
            Set-MsolUser -UserPrincipalName $samname -BlockCredential $true
            Write-Host "Successfully blocked all the sign-ins from this o365 account.." -ForegroundColor Green

            # converts the regular user mailbox to shared
            Set-Mailbox -Identity $samname -Type Shared
            Write-Host "Successfully converted the user's mailbox to 'SHARED'." -ForegroundColor Green

            # pulls all user info
            $adDetails = Get-ADUser -Identity $samname -Properties *
            $o365Details = Get-MsolUser -SearchString $samname
            $exchangeDetails = Get-Mailbox -Identity $samname

            # creates a customobject for to display such changes
            $results = [pscustomobject][ordered] @{
                'SamAccountName'            = $adDetails.SamAccountName
                'AD_Enabled'                = $adDetails.Enabled
                'extensionAttribute1'       = $adDetails.extensionAttribute1
                'extensionAttribute10'      = $adDetails.extensionAttribute10
                'extensionAttribute12'      = $adDetails.extensionAttribute12
                'extensionAttribute14'      = $adDetails.extensionAttribute14
                'extensionAttribute15'      = $adDetails.extensionAttribute15
                'O365_BlockCredential'      = $o365Details.BlockCredential
                'o365_isLicensed'           = $o365Details.isLicensed
                'o365_Licenses'             = $o365Details.Licenses
                'EmailForwardingEnabled'    = $exchangeDetails.DeliverToMailboxAndForward
                'InternalForwardingAddress' = $exchangeDetails.ForwardingAddress
                'ExternalForwardingAddress' = $exchangeDetails.ForwardingSmtpAddress
            }
            $results

        } Else {
            Write-Host ""
            Write-Host "The user: '$samname' does not exist on the domain. Please try again.."
        }
    } Catch {
        Write-Host
        Write-Host "[ERROR] Something unexpected happened. Please try again later: $($_.Exception.Message)`r`n" -ForegroundColor Red
        Write-Host
    }
} ## disables an ad user on-prem and removes the necessary attributes
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

    if (-not ($adminuser)) {
        [string]$adminuser = Read-Host "Please enter your on-prem AD username (\GREATGULF\username)"
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

    if ($CompanyGroup -eq "HTNB") {
        $latestNumber = ($num | Where-Object { $_ -ne "1463" -and $_ -ne "225" } | Sort-Object -Descending | Select-Object -First 1) -as [int]
        $nextNumber = $latestNumber + 1
        $nextComputerName = "$CompanyGroup{00:D3}" -f $nextNumber
    } else {
        $latestNumber = ($num | Sort-Object -Descending | Select-Object -First 1) -as [int]
        $nextNumber = $latestNumber + 1
        $nextComputerName = "$CompanyGroup{0:D4}" -f $nextNumber
    }
    Write-Host
    Write-Host "Next available computer name:" -ForegroundColor Cyan -NoNewline; Write-Host " $nextComputerName" -ForegroundColor Yellow;
    Write-Host

    $createComputer = Read-Host "Do you want to create this computer object? (Y/N)"

    if ($createComputer -eq "Y") {

        Write-Host
        $displayuser = Read-Host "Who will this computer belong to? (username for description)"

        if ($CompanyGroup -eq "THNB") {
            $computerPath = "OU=Computers,OU=TuckerHiRise,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
        } elseif ($CompanyGroup -eq "GGNB") {
            $computerPath = "OU=Computers,OU=GreatGulf,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
        } elseif ($CompanyGroup -eq "HTNB") {
            $computerPath = "OU=Computers,OU=BrockportHS,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
        } elseif ($CompanyGroup -eq "GBSNB") {
            $computerPath = "OU=Computers,OU=GreatBuilderSolutions,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
        } elseif ($CompanyGroup -eq "HCNB") {
            $computerPath = "OU=Computers,OU=HomeCAD,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
        } elseif ($CompanyGroup -eq "FGNB") {
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
} ## creates a computer object under a company prefix
Function Run-MFACycle {

    <#
        .DESCRIPTION

        The Managed Folder Assistant (MFA) is an Exchange Mailbox Assistant that applies and processes the message retention settings
        that are configured in retention policies.

        Exchange Online Archiving can take up to 24 hours to begin archiving email out of the primary mailbox after it is enabled for a user in Microsoft 365.
        Other cause could be if the size of the mailbox in Exchange Online is less than 10 megabytes (MB). The retention policy runs automatically one time every
        seven days for mailboxes that are larger than 10 MB. However, the retention policy doesn’t automatically run for mailboxes that are smaller than 10 MB.

        In some cases, you want to force the Managed Folder Assistant run immediately. MFA does not run immediately and will take some time to process.
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [string]$email
    )

    # This runs the Start-ManagedFolderAssistant command to force the MFA runs on a single mailbox

    Write-Host
    Write-Host "Running the ManagedFolderAssistant cmdlet for the user: " -NoNewline; Write-Host "$email" -ForegroundColor Yellow
    Write-Host
    Write-Host "--------------"
    Write-Host "----------------------------------"
    Write-Host "---------------------------------------------"
    Write-Host "-------------------------------------------------------"
    Start-ManagedFolderAssistant -Identity $email -Verbose
    Write-Host "-------------------------------------------------------"
    Write-Host "---------------------------------------------"
    Write-Host "----------------------------------"
    Write-Host "--------------"
    Write-Host
    Write-Host "........PROCESSING DONE............" -ForegroundColor Yellow

    # Checks the size of the mailbox of the $email user

    $itemsize = Get-MailboxStatistics -Identity $email | Select-Object DisplayName, MailboxTypeDetail, IsValid, ItemCount, @{Name = "totalItemSize"; e = { $_.TotalItemSize } }

    # This block checks the lats time Managed Folder Assistant ran on the $email variable

    $logProps = Export-MailboxDiagnosticLogs $email -ExtendedProperties
    $xmlprops = [xml]($logProps.MailboxLog)
    $LastProcessed = ($xmlprops.Properties.MailboxTable.Property | Where-Object { $_.Name -like "*ELCLastSuccessTimestamp*" }).Value
    $ItemsDeleted = $xmlprops.Properties.MailboxTable.Property | Where-Object { $_.Name -like "*ElcLastRunDeletedFromRootItemCount*" }

    #creating a custom object to display all results

    $ReportLine = [PSCustomObject]@{
        DisplayName        = $itemsize.DisplayName
        EmailAdress        = $email
        MailboxTypeDetail  = $itemsize.MailboxTypeDetail
        IsValid            = $itemsize.IsValid
        ItemCount          = $itemsize.ItemCount
        CurrentMailboxSize = $($itemsize.TotalItemSize)
        MFA_LastProcessed  = $LastProcessed
        ItemsDeleted       = $ItemsDeleted.Value
    }

    Write-Host "................................................."
    Write-Host "......................................."
    Write-Host
    Write-Host "Here are the results: " -ForegroundColor Yellow -NoNewline
    $ReportLine | Format-List

} ## this is to force MFA to apply the retention policies









