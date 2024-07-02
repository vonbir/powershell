Function Get-AADG {
    <#
        .DESCRIPTION
        This function pulls all the Azure AD groups for the specified user.
        `

        .EXAMPLE
        Get-AADG -upn Brylle.Purificacion@greatgulf.com
        `
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string]$upn
    )

    $requiredModules = @("AzureAD")
    $ErrorActionPreference = 'SilentlyContinue'

    foreach ($module in $requiredModules) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            Write-Host "Installing module: $module"
            Install-Module -Name $module -Force -AllowClobber
        }
    }

    $TestAzureADConnection = Get-AzureADCurrentSessionInfo

    if (-not ($TestAzureADConnection)) {
        Write-Host "Connecting to Azure AD..." -ForegroundColor DarkYellow
        Connect-AzureAD
        Write-Host "Successfully connected to AzureAD..." -ForegroundColor Yellow
    } else {
        Write-Host "Successfully connected to Azure AD..." -ForegroundColor Yellow
    }

    Try {
        $aadUser = Get-AzureADUser -SearchString $upn
        $aadGroup = Get-AzureADUserMembership -ObjectId $aadUser.ObjectId
        $aadGroup | Select-Object DisplayName, ObjectType, ObjectID
    } Catch {
        Write-Host $Error[0] -ForegroundColor Red
        Write-Host "Something went wrong, please try running the command again......." -ForegroundColor Yellow
    }
}