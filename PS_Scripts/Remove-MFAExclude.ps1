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

    $requiredModules = @("MSOnline")
    $ErrorActionPreference = 'SilentlyContinue'

    foreach ($module in $requiredModules) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            Write-Host "Installing module: $module"
            Install-Module -Name $module -Force -AllowClobber
        }
    }

    if (-not (Get-MsolAccountSku)) {
        Write-Host "Connecting to the MSOnline module..."
        Connect-MsolService
        Write-Host "Successfully connected to the MSOnline module." -ForegroundColor Yellow
    } else {
        Write-Host "Successfully connected to the MSOnline module." -ForegroundColor Yellow
    }

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