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
        $adminuser = Read-Host "Please enter your on-prem AD username (tabooresort\username)"
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

        $containerDN = "OU=Staff Users,DC=tabooresort,DC=com"
        $useremail = "$SamAccountName@taboomuskoka.com"
        $streetAddress = "1209 Muskoka Beach Rd"
        $City = "Gravenhurst"
        $PostalCode = "P1P 1R1"

        # Create user object
        New-ADUser @splatADUser -Name $Name -Credential $Cred -UserPrincipalName "$SamAccountName@tabooresort.com" -SamAccountName $SamAccountName -DisplayName $Name -PasswordNeverExpires $true -Path $containerDN -EmailAddress $useremail

        Start-Sleep -Seconds 1

        $user = Get-ADUser -Identity $SamAccountName -Properties *

        # Set extension attributes
        if ($user) {
            Set-ADUser -Identity $user.DistinguishedName -Credential $cred -Title $splatADUser.Description -Department $splatADUser.Department `
                -StreetAddress $streetAddress -City $City -PostalCode $PostalCode -Country CA -State ON
        }

        # Output the created user details
        Write-Host
        Write-Host -ForegroundColor Yellow "The user has been created successfully!"
        Get-ADUser -Identity $SamAccountName
    } Catch {
        Write-Host
        Write-Host "[ERROR]`t Oops, something went wrong: $($_.Exception.Message)`r`n" -ForegroundColor Red
        Write-Host
    }
}