Function Get-ADG {
    <#
        .DESCRIPTION
        This function pulls all the on-prem AD groups of a specified user.
        `

        .EXAMPLE
        Get-ADG -upn Brylle.Purificacion
        `
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string]$upn
    )

    $requiredModules = @("ActiveDirectory")
    $ErrorActionPreference = 'SilentlyContinue'

    foreach ($module in $requiredModules) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            Write-Host "Installing module: $module"
            Install-Module -Name $module -Force -AllowClobber
        }
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

    Try {
        $adGroup = Get-ADPrincipalGroupMembership -Identity $upn -Credential $Cred
        $adGroup | Select-Object Name
    } Catch {
        Write-Host $Error[0] -ForegroundColor Red
        Write-Host "Something went wrong, please try running the function again......." -ForegroundColor Yellow
    }
}