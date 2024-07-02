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