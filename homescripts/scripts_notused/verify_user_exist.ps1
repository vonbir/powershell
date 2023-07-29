
Param(
    [Parameter(Mandatory)]
    [string]$upn
)

while ($upn) {
    try {
        $user = Get-MsolUser -UserPrincipalName $upn -ErrorAction Stop | Select-Object DisplayName, Title, Department, City, Office, StreetAddress, State, PhoneNumber, isLicensed, Licenses, ObjectID, userPrincipalName

        $groups = Get-AzureADUserMembership -ObjectId $user.ObjectId | Where-Object {$_.ObjectType -eq "Group"}

        $user
        $groups | Select-Object ObjectId, DisplayName, Description | Format-Table

        $retry = Read-Host "Would you like to enter another user? (Y/N)"

        if ($retry -ne "Y") {
            break
        }

        $upn = Read-Host "Please enter the user's email"
    }
    catch {
        Write-Host "Username does not exist, please try again." -ForegroundColor Yellow
        $upn = Read-Host "Please enter the user's email"
    }
}


