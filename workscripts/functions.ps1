Function Get-ADG {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string]$upn
    )
    Try {
        $adGroup = Get-ADPrincipalGroupMembership -Identity $upn
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

    # Retrieve the group
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

    # Remove user from the group
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
                isLicensed        = $_.isLicensed
                Licenses          = $_.Licenses
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
                RecipientType             = $_.RecipientType
                AccountDisabled           = $_.AccountDisabled
                userPrincipalName         = $_.userPrincipalName
                msexchHideFromAddressBook = $_.HiddenFromAddressListsEnabled
                TerminationDate           = $_.customAttribute15
                ForwardingSmtpAddress     = $_.ForwardingSmtpAddress
                ForwardingAddress         = $_.ForwardingSmtpAddress
                EmailForwardingStatus     = $_.DeliverToMailboxAndForward
            }
        }

        # Create a custom object with the desired properties
        $results = [PSCustomObject]@{
            userPrincipalName         = $user.userPrincipalName
            AccountEnabled            = $AzureADUser.AccountEnabled
            RecipientTypeDetails      = $mailbox.RecipientTypeDetails
            RecipientType             = $mailbox.RecipientType
            jobTitle                  = $azureADUser.jobTitle
            StreetAddress             = $azureADUser.StreetAddress
            State                     = $azureADUser.State
            TelephoneNumber           = $azureADUser.TelephoneNumber
            PostalCode                = $AzureADUser.PostalCode
            City                      = $AzureADUser.City
            Department                = $AzureADUser.Department
            CompanyName               = $AzureADUser.CompanyName
            o365_groups               = $groups.DisplayName
            isLicensed                = $user.isLicensed
            Licenses                  = $user.Licenses
            msexchHideFromAddressBook = $mailbox.msexchHideFromAddressBook
            blockedCredential         = $user.blockedCredential
            EmailForwardingStatus     = $mailbox.EmailForwardingStatus
            ForwardingSmtpAddress     = $mailbox.ForwardingSmtpAddress
            ForwardingAddress         = $mailbox.ForwardingAddress
            TerminationDate           = $mailbox.TerminationDate
        }
        $results | Format-List *
    } Catch {
        Write-Host "The user does not exist. Please try again later.." -ForegroundColor Red -BackgroundColor Yellow
    }
}
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
            Company         = Read-Host "Enter the user's company"
            #Manager = Read-Host "Enter the user's Reporting Manager"
            Enabled         = $true
        }

        [string]$SamAccountName = $($splatADUser.GivenName) + "." + $($splatADUser.Surname)
        [string]$Name = $($splatADUser.GivenName) + " " + $($splatADUser.Surname)

        [string]$containerInput = Read-Host ("Enter the container division for this user (GG,FG,THR,GBS,HT,DD,TM)")
        $containerinput = $containerInput.ToUpper()
        $extensionAttribute1 = $containerInput
        [string]$extensionAttribute2 = Read-Host "Enter extension attribute 2 value (License Type: E3/F3 or not?)"
        [string]$extensionAttribute10 = Read-Host "Enter extension attribute 10 value (Hiring date, yyyy/MM/dd)"
        [string]$extensionAttribute14 = Read-Host "Enter extension attribute 14 value (AADSyncTrue or not?)"

        # Set container DN based on user's input
        if ($containerInput -match "GG") {
            $containerDN = "OU=Users,OU=GreatGulf,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
            $useremail = "$SamAccountName@greatgulf.com"
            $streetAddress = "351 King Street East, 13th Floor"
            $City = "Toronto"
            $PostalCode = "M5A 0L6"
        } elseif ($containerInput -eq "FG") {
            $containerDN = "OU=Users,OU=FirstGulf,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
            $useremail = "$($splatADUser.GivenName.Substring(0,1))$($splatADUser.Surname)@firstgulf.com"
            $streetAddress = "351 King Street East, 13th Floor"
            $City = "Toronto"
            $PostalCode = "M5A 0L6"
        } elseif ($containerInput -eq "THR") {
            $containerDN = "OU=Users,OU=TuckerHiRise,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
            $useremail = "$SamAccountName@tuckerhirise.com"
            $streetAddress = "351 King Street East, 13th Floor"
            $City = "Toronto"
            $PostalCode = "M5A 0L6"
        } elseif ($containerInput -eq "GBS") {
            $containerDN = "OU=Users,OU=GreatBuilderSolutions,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
            $useremail = "$SamAccountName@greatbuildersolutions.com"
            $streetAddress = "351 King Street East, 13th Floor"
            $City = "Toronto"
            $PostalCode = "M5A 0L6"
        } elseif ($containerInput -eq "HT") {
            $containerDN = "OU=Users,OU=BrockportHS,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
            $useremail = "$SamAccountName@hometechnology.com"
            $streetAddress = "200 Brockport Drive"
            $City = "Etobicoke"
            $PostalCode = "M9W 5C9"
        } elseif ($containerInput -eq "DD") {
            $containerDN = "OU=Users,OU=HomeCAD,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
            $useremail = "$SamAccountName@draftdesign.ca"
            $streetAddress = "200 Brockport Drive"
            $City = "Etobicoke"
            $PostalCode = "M9W 5C9"
        } elseif ($containerInput -eq "TM") {
            $containerDN = "OU=Users,OU=TabooMuskoka,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
            $useremail = "$SamAccountName@taboomuskoka.com"
            $streetAddress = "1209 Muskoka Beach Rd"
            $City = "Gravenhurst"
            $PostalCode = "P1P 1R1"
        }
        # Create user object
        New-ADUser -Name $name -Path $containerDN -Credential $Cred -EmailAddress $useremail -UserPrincipalName "$SamAccountName@greatgulf.biz" -SamAccountName $SamAccountName -DisplayName $Name -PasswordNeverExpires $true

        $user = Get-ADUser -Identity $SamAccountName -Properties *

        # Set extension attributes
        if ($extensionAttribute14 -eq "AADSyncTrue") {
            Set-ADUser -Identity $user.DistinguishedName -Add @{extensionAttribute1 = $extensionAttribute1; extensionAttribute2 = $extensionAttribute2; extensionAttribute10 = $extensionAttribute10; extensionAttribute14 = $extensionAttribute14 } -Credential $Cred -Title $splatADUser.Description -Department $splatADUser.Department `
                -StreetAddress $streetAddress -City $City -PostalCode $PostalCode -Country CA -State ON
        } else {
            Set-ADUser -Identity $user.DistinguishedName -Add @{extensionAttribute1 = $extensionAttribute1; extensionAttribute10 = $extensionAttribute10 } -Clear extensionAttribute2, extensionAttribute14 -Credential $cred -Title $splatADUser.Description -Department $splatADUser.Department `
                -StreetAddress $streetAddress -City $City -PostalCode $PostalCode -Country CA -State ON
        }

        # Output the created user details
        Write-Host
        Write-Host -ForegroundColor Yellow "The user has been created successfully!"
        Write-Host
        Get-ADUser -Identity $SamAccountName
    } Catch {
        Write-Host
        Write-Host "[ERROR]`t Oops, something went wrong: $($_.Exception.Message)`r`n" -ForegroundColor Red
        Write-Host
    }
}
Function Offboard-ADUser {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [string]$UserPrincipalName
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
        Write-Host
        $adminuser = Read-Host "Please enter your on-prem AD username (GREATGULF\username)"
        $adminpass = Read-Host "Please enter your on-prem AD password" -AsSecureString
        $Cred = New-Object System.Management.Automation.PSCredential $adminuser, $adminpass
    }
    Write-Host
    Write-Host "You are currently logged in as: " -NoNewline; Write-Host "$adminuser" -ForegroundColor Yellow
    Write-Host

    # current date
    $date = Get-Date -Format yyyy/MM/dd

    try {
        if ($UserPrincipalName) {
            # disables the AD account
            Disable-ADAccount -Identity $UserPrincipalName -Credential $Cred
            Write-Host "--------------------------------------"
            Write-Host "Successfully disabled the user: $UserPrincipalName" -ForegroundColor Green

            # pulls all user info
            $adDetails = Get-ADUser -Identity $UserPrincipalName -Properties *
            $o365Details = Get-MsolUser -SearchString $UserPrincipalName
            $exchangeDetails = Get-Mailbox -Identity $UserPrincipalName

            # removes all AD groups
            Get-ADUser -Identity $UserPrincipalName -Properties MemberOf | ForEach-Object {
                $_.MemberOf | Remove-ADGroupMember -Credential $Cred -Members $_.DistinguishedName -Confirm:$false
                Write-Host "Successfully removed the user $UserPrincipalName from all the on-prem AD groups" -ForegroundColor Green
            }

            # puts the current termination date
            Set-ADUser -Identity $UserPrincipalName -Replace @{extensionAttribute15 = "$date" } -Credential $Cred
            Write-Host "The termination date has been set to: $date" -ForegroundColor Green
            Write-Host "The E3 license has been retained, waiting for the mailbox to be converted to SHARED." -ForegroundColor Green

            # hides the user from the global adddress book
            Set-ADUser -Identity $UserPrincipalName -Add @{msExchHideFromAddressLists = $true } -Credential $Cred
            Write-Host "The msExchHideFromAddressLists attribute has been set to: 'TRUE'" -ForegroundColor Green

            # initiate sign-out of all office 365 sessions by revoking the refresh tokens issue to applications for a use
            Get-AzureADUser -SearchString $UserPrincipalName | revoke-azureaduserallrefreshtoken
            Write-Host "Successfully initiated sign-out of all o365 sessions for this user.." -ForegroundColor Green

            # blocks sign-in from this o365 account
            set-msoluser -ObjectId $o365Details.ObjectId -BlockCredential $true
            Write-Host "Successfully blocked all the sign-ins from this o365 account.." -ForegroundColor Green

            # converts the regular user mailbox to shared, this shouldnt work anymore as it needs exchange admin priv.
            #Set-Mailbox -Identity $UserPrincipalName -Type Shared
            #Write-Host "Successfully converted the user's mailbox to 'SHARED'." -ForegroundColor Green

            Write-Host
            Get-ADUser -Identity $UserPrincipalName -Properties * | Select-Object DistinguishedName, Enabled, SamAccountName, UserPrincipalName, extension*
            Write-Host
        } Else {
            Write-Host ""
            Write-Host "The user: '$UserPrincipalName' does not exist on the domain. Please try again.."
        }
    } Catch {
        Write-Host
        Write-Host "[ERROR] Something unexpected happened. Please try again later: $($_.Exception.Message)`r`n" -ForegroundColor Red
        Write-Host
    }
}
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

    # This block checks the last time Managed Folder Assistant ran on the $email variable

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

}
Function Set-EmailForwarding {

    <#
        .DESCRIPTION
        This function enables email forwarding for the specified user's mailbox and sets the forwarding address.

        .PARAMETER EmailAddress
        The email address of the user.

        .PARAMETER ForwardingAddress
        The email address to which emails will be forwarded.

        .EXAMPLE
        Set-EmailForwarding -EmailAddress user@example.com -ForwardingAddress forwarding@example.com
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [string]$EmailAddress,
        [string]$ForwardingAddress
    )
    try {
        if ($EmailAddress) {
            Write-Host "The user: " -NoNewline
            Write-Host "'$EmailAddress'" -ForegroundColor Yellow -NoNewline
            Write-Host " has been found..."
            Set-Mailbox -Identity $EmailAddress -DeliverToMailboxAndForward $true -ForwardingAddress $ForwardingAddress
            Start-Sleep -Seconds 2
            Write-Host "Email forwarding has been successfully enabled for this user..." -ForegroundColor Yellow
            Write-Host "The forwarding address for $EmailAddress's mailbox has been set to $ForwardingAddress" -ForegroundColor Green
        } else {
            Write-Host "The user does not exist, please try again later.." -ForegroundColor Red
        }
    } catch {
        Write-Error "An error occurred: $($_.Exception.Message)"
    }
}
Function Get-MailboxSize {

    <#
        .DESCRIPTION
        `

        .EXAMPLE
        `
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [string]$UserPrincipalName #firstname.lastname
    )


    $userdetails = get-Mailbox -Identity $UserPrincipalName | Select-Object Name, PrimarySmtpAddress

    $mailboxsize = Get-MailboxStatistics -Identity $UserPrincipalName | Select-Object ItemCount, TotalItemSize

    $results = [ordered]@{
        'MailboxOwner'        = $userdetails.Name
        'MailboxEmailAddress' = $userdetails.PrimarySmtpAddress
        'MailboxSize'         = $mailboxsize.TotalItemSize
        'TotalEmailCount'     = $mailboxsize.ItemCount
    }
    $results
}
## Start ADUC As Admin
Function Start-ADUC {
    Param (
        [parameter(Position = 0, ParameterSetName = "AsAdmin")]
        [switch]$AsAdmin
    )
    If ($AsAdmin) {
        $adminuser = Read-Host "Please enter your on-prem AD username (GREATGULF\username)"
        $adminpass = Read-Host "Please enter your on-prem AD password" -AsSecureString
        $Cred = New-Object System.Management.Automation.PSCredential $adminuser, $adminpass
        Start-Process powershell -Credential $Cred -ArgumentList "Start-Process -FilePath '$SystemRoot\System32\mmc.exe' -ArgumentList '$SystemRoot\System32\dsa.msc' -Verb RunAs"
    } Else { Start-Process dsa.msc }
}

Function Get-ADLogonTime {

    <#
        .DESCRIPTION
        `

        .EXAMPLE
        `
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [string]$UserPrincipalName #firstname.lastname
    )

    Write-Host
    Write-Host "*USER LOGON DETAILS:" -ForegroundColor Yellow
    Write-Host
    $result = Get-ADUser -Identity $UserPrincipalName -Properties * | Select-Object Name, SamAccountName, emailAddress, LastLogonDate, logonCount | Out-String -Width 4096 | ForEach-Object { $_.Trim() }
    $result
    Write-Host ".................................................."
    Write-Host ".................................................."
    Write-Host ""
}
Function Get-LapsPassword {
    <#
        .DESCRIPTION
        `

        .EXAMPLE
        `
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [string]$Hostname #this is the hostname of the computer
    )
    if (-not (Get-Module -Name ActiveDirectory -ListAvailable)) {
        Add-WindowsFeature AD-Domain-Services
        Import-Module ActiveDirectory
        Write-Host "Successfully imported the ActiveDirectory module, please go ahead and proceed.." -ForegroundColor Yellow
    }
    if (-not ($adminuser)) {
        Write-Host
        $adminuser = Read-Host "Please enter your on-prem AD username (GREATGULF\username)"
        $adminpass = Read-Host "Please enter your on-prem AD password" -AsSecureString
        $Cred = New-Object System.Management.Automation.PSCredential $adminuser, $adminpass
    }
    Write-Host
    Write-Host "You are currently logged in as: " -NoNewline; Write-Host "$adminuser" -ForegroundColor Yellow
    Write-Host
    Get-LapsADPassword -Identity $Hostname -AsPlainText -DomainController KSEDC01 -Credential $Cred | Select-Object ComputerName, DistinguishedName, Account, Password, PasswordUpdateTime, ExpirationTImestamp
}
Function Unlock-ADUser {
    <#
        .DESCRIPTION
        `

        .EXAMPLE
        `
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [string]$UserPrincipalName #this is the hostname of the computer
    )
    if (-not ($adminuser)) {
        Write-Host
        $adminuser = Read-Host "Please enter your on-prem AD username (GREATGULF\username)"
        $adminpass = Read-Host "Please enter your on-prem AD password" -AsSecureString
        $Cred = New-Object System.Management.Automation.PSCredential $adminuser, $adminpass
    }
    Write-Host
    Write-Host "You are currently logged in as: " -NoNewline; Write-Host "$adminuser" -ForegroundColor Yellow
    Write-Host
    Unlock-ADAccount -Identity $UserPrincipalName -Credential $Cred
    Get-ADUser -Identity $UserPrincipalName -Properties * | Select-Object Name, SamAccountName, UserPrincipalName, LockedOut
}

Function Copy-ADGroups {
    <#
        .DESCRIPTION
        Replicates the group that a user is a part of to another user.
        `

        .EXAMPLE
        `
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [string]$from, #the user that groups will be copied from
        [Parameter(Mandatory)]
        [string]$to #this is the user that groups will be copied to
    )

    try {
        if (-not ($adminuser)) {
            Write-Host
            $adminuser = Read-Host "Please enter your on-prem AD username (GREATGULF\username)"
            $adminpass = Read-Host "Please enter your on-prem AD password" -AsSecureString
            $Cred = New-Object System.Management.Automation.PSCredential $adminuser, $adminpass
        }
        Write-Host
        Write-Host "You are currently logged in as: " -NoNewline; Write-Host "$adminuser" -ForegroundColor Yellow
        Write-Host
        $groups = Get-ADPrincipalGroupMembership -Identity $from | Where-Object Name -NE "Domain Users"

        foreach ($group in $groups) {
            Add-ADGroupMember -Identity $group -Members $to -Credential $Cred
        }
        Get-ADPrincipalGroupMembership -Identity $to | Select-Object Name

    } catch {
        Write-Host "An error has occurred, please try again later..."
    }

}

Function Add-MFAExclude {
    <#
        .DESCRIPTION
        Adds the user to the MFA Exclude security group, please make sure to remove it after through the Remove-MFAExclude cmdlet.
        `

        .EXAMPLE
        Add-MFAEclude -useremail Brylle.Purificacion@greatgulf.com
        `
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [string]$useremail #the user that will be added to the 'MFA Exclude' group, remember to remove it after
    )

    try {

        $userobjectid = Get-MsolUser -SearchString $useremail

        if ($userobjectid) {
            Write-Host
            Write-Host "Would you like to add the user " -NoNewline
            Write-Host "'$($userobjectid.DisplayName)' " -ForegroundColor Yellow -NoNewline
            Write-Host "to the MFA Exclude group? (Y/N): " -NoNewline
            $proceed = Read-Host
            Write-Host

            if ($proceed -eq 'Y') {
                Add-MsolGroupMember -GroupObjectId d228403a-1cfd-41b5-a2a4-c5da10d322fa -GroupMemberType User -GroupMemberObjectId $userobjectid.ObjectId
                Write-Host
                Write-Host "The user has been successfully added to the 'MFA Exclude' group." -ForegroundColor Yellow
                Write-Host
            }
        }
    } catch {
        Write-Host "An error has occurred, please try again later..."
    }
}

Function Remove-MFAExclude {
    <#
        .DESCRIPTION
        Removes the user to the MFA Exclude security group.
        `

        .EXAMPLE
        Remove-MFAExclude -useremail Brylle.Purificacion@greatgulf.com
        `
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [string]$useremail #the user that will be removed form the MFA Exclude group
    )

    try {

        $userobjectid = Get-MsolUser -SearchString $useremail

        if ($userobjectid) {
            Write-Host
            Write-Host "Would you like to remove the user " -NoNewline
            Write-Host "'$($userobjectid.DisplayName)' " -ForegroundColor Yellow -NoNewline
            Write-Host "to the MFA Exclude group? (Y/N): " -NoNewline
            $proceed = Read-Host
            Write-Host

            if ($proceed -eq 'Y') {
                Remove-MsolGroupMember -GroupObjectId d228403a-1cfd-41b5-a2a4-c5da10d322fa -GroupMemberType User -GroupMemberObjectId $userobjectid.ObjectId
                Write-Host
                Write-Host "The user has been successfully removed from the 'MFA Exclude' group." -ForegroundColor Yellow
                Write-Host
            }
        } else {
            Write-Host "The operation has been cancelled..."
        }
    } catch {
        Write-Host "An error has occurred, please try again later..."
    }
}

# Get the path to the current user's PowerShell profile script
# $profilePath = $PROFILE.AllUsersCurrentHost

# # Check if the profile script file exists
# if (Test-Path $profilePath) {
#     # Check if the function is already defined in the profile
#     $functionName = "Get-LapsPassword"
#     $profileContent = Get-Content $profilePath
#     if ($profileContent -notmatch "function $functionName") {
#         # Append the function definition to the profile script
#         "function $functionName {
#             Write-Host 'This is my custom function!'
#         }" | Out-File -Append -FilePath $profilePath
#         Write-Host "Function $functionName added to $profilePath"
#     } else {
#         Write-Host "Function $functionName is already defined in $profilePath"
#     }
# } else {
#     Write-Host "Profile script not found at $profilePath"
# }



# if (not(Test-Path -Path $PROFILE)) {
#     New-Item -Type File -Path $PROFILE -Force
#     Set-Content -Path $PROFILE -Value {

#     }
# }




