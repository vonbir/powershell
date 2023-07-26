Param(
    [Parameter(Mandatory)]
    [string]$CsvPath
)

try {
    $users = Import-Csv -Path $CsvPath
} catch {
    Write-Host "Failed to read the CSV file. Please ensure the file path is correct." -ForegroundColor Red
    exit
}

$allUserInformation = foreach ($user in $users) {
    $upn = $user.userPrincipalName
        try {
            $userObject = Get-MsolUser -UserPrincipalName $upn -ErrorAction Stop | Select-Object DisplayName, Title, Department, City, Office, StreetAddress, State, PhoneNumber, isLicensed, Licenses, ObjectID, userPrincipalName
            $userObject
        }
        catch {
            Write-Host -ForegroundColor DarkRed "The user does not exist, please try again."
            break
        }
    }

$exportOption = Read-Host "Do you want to export the retrieved user information to a CSV file? (Y/N)"

if ($exportOption -eq "Y" -or $exportOption -eq "Yes") {
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $exportPath = "C:\Users\brylle.purificacion\OneDrive - Great Gulf Group\Desktop\export.csv"
    $allUserInformation | Export-Csv -Path $exportPath -NoTypeInformation
    Write-Host "User information exported to $exportPath." -ForegroundColor Green
}