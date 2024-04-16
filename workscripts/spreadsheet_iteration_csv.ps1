
# This script allows you to create multiple microsoft 365 users with customAttributes assigned

$csvFilePath = "C:\Users\brylle.purificacion\OneDrive - Great Gulf Group\Desktop\TABOO.csv"

# Import the CSV file
$csvData = Import-Csv -Path $csvFilePath

# Iterate through each row in the CSV

# create a custom object for each row in the CSV file for better object manipulation
$customUsers = foreach ($row in $csvData) {
    [PSCustomObject]@{
        EmailAddress      = $row.EmailAddress
        JobTitle          = $row.JobTitle
        CustomAttribute1  = $row.CustomAttribute1
        CustomAttribute10 = $row.CustomAttribute10
        Department        = $row.Department
        Office            = $row.Office
        StreetAddress     = $row.StreetAddress
        City              = $row.City
        postalCode        = $row.postalCode
        Country           = $row.Country
        State             = $row.State
    }
}

# creates a foreach loop that goes through each user and assigns the respective attribute values
$totalusers = foreach ($user in $customUsers) {

    Set-AzureADUserExtension -ObjectId $user.EmailAddress -ExtensionName ExtensionAttribute1 -ExtensionValue "TM"
    Write-Host -ForegroundColor Yellow "Successfully set the customAttribute1 to '$($user.customAttribute1)'"
    Set-AzureADUserExtension -ObjectId $user -ExtensionName ExtensionAttribute10 -ExtensionValue $user.CustomAttribute10
    Write-Host -ForegroundColor Yellow "Successfully set the customAttribute10 to '$($user.customAttribute10)'"
    Set-AzureADUserExtension -ObjectId $user -ExtensionName ExtensionAttribute2 -ExtensionValue $user.CustomAttribute2
    Write-Host -ForegroundColor Yellow "Successfully set the customAttribute2 to '$($user.customAttribute2)'"
    Set-MsolUser -UserPrincipalName $user.EmailAddress -Title $user.JobTitle


}



#Set-AzureADUserExtension -ObjectId $user -ExtensionName ExtensionAttribute2 -ExtensionValue "Unmanaged"
#Write-Host "extensionAttribute2 'Unmanaged' has been SUCCESSFULLY added for $user.."
}

# $totalusers = foreach ($user in $csvData.userPrincipalName) {
#    Get-MailboxStatistics -Identity $user | Select-Object DisplayName, TotalItemSize, $csvData.isLicensed, @{N = "Licenses"; E = { $csvData.Licenses.AccountSkuId } }
#}

$totalusers | Sort-Object -Descending

# for modifying Microsoft 365 attributes in bulk through a foreach loop
$totalusers = foreach ($user in $customUsers) {
    Set-MsolUser -UserPrincipalName $user.EmailAddress -Department $user.Department -Office $user.Office -StreetAddress $user.StreetAddress -City $user.City -PostalCode $user.PostalCode -Country $user.Country -State $user.State
}


# This is a script that allows you to run a line and iterate through rows of a spreadsheet