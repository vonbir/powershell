Function Unlock-ADUser {
    <#
        .DESCRIPTION
        This function unlocks an Active Directory user account.
        `

        .EXAMPLE
        Unlock-ADUser -UserPrincipalName Brylle.Purificacion
        `
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [string]$UserPrincipalName #this is the userprincipalname of the user.
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