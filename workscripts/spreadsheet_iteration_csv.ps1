Function Import-M365Users {

    # This script allows you to create multiple microsoft 365 users with customAttributes assigned

    # declare the csv spreadsheet file path
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [string]$csvFilePath
    )
    # Import the CSV file

    $csvData = Import-Csv -Path $csvFilePath

    # Iterate through each row in the CSV

    # create a custom object for each row in the CSV file for better object manipulation
    $customUsers = foreach ($row in $csvData) {
        [PSCustomObject]@{
            userPrincipalName = $row.userPrincipalName
            FirstName         = $row.FirstName
            LastName          = $row.LastName
            DisplayName       = $row.FirstName + " " + $row.LastName
            jobTitle          = $row.JobTitle
            CustomAttribute1  = $row.CustomAttribute1
            CustomAttribute10 = $row.CustomAttribute10
            CustomAttribute12 = $row.CustomAttribute12
            CustomAttribute2  = $row.CustomAttribute2
            reportingManager  = $row.reportingManager
            Department        = $row.Department
            Office            = $row.Office
            StreetAddress     = $row.StreetAddress
            City              = $row.City
            postalCode        = $row.postalCode
            Country           = $row.Country
            State             = $row.State
            Password          = $row.Password
        }
    }

    # creates a foreach loop that goes through each user and assigns the respective attribute values
    foreach ($user in $customUsers) {

        $userCheck = Get-MsolUser -UserPrincipalName $user.userPrincipalName

        if ($null -eq $userCheck) {

            New-MsolUser -UserPrincipalName $user.userPrincipalName -DisplayName $user.DisplayName -Title $user.jobTitle -City $user.City -Country $user.Country -Department $user.Department -FirstName $user.FirstName -LastName $user.LastName -Office $user.Office -PostalCode $user.postalCode -State $user.State -StreetAddress $user.StreetAddress

            $userCheck2 = Get-AzureADUser -ObjectId $user.userPrincipalName

            if ($userCheck2) {
                Set-MsolUserPassword -UserPrincipalName $user.userPrincipalName -NewPassword $user.Password # sets the password
                Set-AzureADUserExtension -ObjectId $user.userPrincipalName -ExtensionName ExtensionAttribute1 -ExtensionValue $user.customAttribute1
                Set-AzureADUserExtension -ObjectId $user.userPrincipalName -ExtensionName ExtensionAttribute10 -ExtensionValue $user.CustomAttribute10
                Set-AzureADUserExtension -ObjectId $user.userPrincipalName -ExtensionName ExtensionAttribute2 -ExtensionValue $user.CustomAttribute2
                Set-AzureADUserExtension -ObjectId $user.userPrincipalName -ExtensionName ExtensionAttribute12 -ExtensionValue $user.CustomAttribute12
                Write-Host -ForegroundColor Yellow "The following user '$($user.userPrincipalName)' has been successfully created."
            }
        } else {
            Set-MsolUserPassword -UserPrincipalName $user.userPrincipalName -NewPassword $user.Password # sets the password
            Set-AzureADUserExtension -ObjectId $user.userPrincipalName -ExtensionName ExtensionAttribute1 -ExtensionValue $user.customAttribute1
            Set-AzureADUserExtension -ObjectId $user.userPrincipalName -ExtensionName ExtensionAttribute10 -ExtensionValue $user.CustomAttribute10
            Set-AzureADUserExtension -ObjectId $user.userPrincipalName -ExtensionName ExtensionAttribute2 -ExtensionValue $user.CustomAttribute2
            Set-AzureADUserExtension -ObjectId $user.userPrincipalName -ExtensionName ExtensionAttribute12 -ExtensionValue $user.CustomAttribute12
            Write-Host -ForegroundColor Yellow "The following user '$($user.userPrincipalName)' has been successfully updated."
        }
    }

}
