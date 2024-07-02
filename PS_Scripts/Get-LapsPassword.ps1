Function Get-LapsPassword {
    <#
        .DESCRIPTION
        This function pulls the LAPS password of a specified hostname/computer.
        `

        .EXAMPLE
        Get-LapsPassword -hostname GGNB0654
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