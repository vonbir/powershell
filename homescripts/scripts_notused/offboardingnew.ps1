
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