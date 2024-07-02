Function Onboard-365User {
    [CmdletBinding()]
    Param()

    # Check if Active Directory module is installed
    if (-not (Get-Module -Name MSOnline -ListAvailable)) {
        Write-Host "MSOnline module not found. Installing the module..."
        Install-Module -Name MSOnline -Scope CurrentUser -Force
    }

    # Import module
    Import-Module -Name MSOnline

    # Prompt for user details

    Try {
        $splatADUser = [ordered]@{
            Firstname         = Read-Host "Enter the first name"
            Surname           = Read-Host "Enter the last name"
            accountPassword   = Read-Host "Enter the password" -AsSecureString
            UserPrincipalName = Read-Host "Enter the user's email address"
            $userLicense      = Read-Host “Enter the license type (E3/Unmanaged)”
            jobTitle          = Read-Host "Enter the user's Job Title"
            Department        = Read-Host "Enter the user's Department"
            Company           = Read-Host "Enter the user's company"
            #Manager = Read-Host "Enter the user's Reporting Manager"
            Enabled           = $true
            usageLocation     = "CA"
        }

        [string]$Displayname = $($splatADUser.Firstname) + " " + $($splatADUser.Surname)

        if ($userLicense -eq 'E3') {
            New-MsolUser -UserPrincipalName $splatADUser.UserPrincipalName -DisplayName $Displayname -FirstName $splatAdUser.Firstname -LastName $splatADUser.Surname -UsageLocation $splatADUser.usageLocation -LicenseAssignment "greatbuildersolutions:SPE_E3"
        } elseif ($userLicense -eq 'Unmanaged') {
            New-MsolUser -UserPrincipalName $splatADUser.UserPrincipalName -DisplayName $Displayname -FirstName $splatAdUser.Firstname -LastName $splatADUser.Surname -UsageLocation splatADUser.usageLocation -LicenseAssignment "greatbuildersolutions:DESKLESSPACK"
        }

    } Catch {
        Write-Host
        Write-Host "[ERROR]`t Oops, something went wrong: $($_.Exception.Message)`r`n" -ForegroundColor Red
        Write-Host
    }
}