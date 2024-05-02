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
        $userCheck = Get-MsolUser -UserPrincipalName $user.UserPrincipalName

        if (-not $userCheck) {
            # Create the user if not already exists
            $userCreate = New-MsolUser -UserPrincipalName $user.userPrincipalName -DisplayName $user.DisplayName -Title $user.jobTitle -City $user.City -Country $user.Country -Department $user.Department -FirstName $user.FirstName -LastName $user.LastName -Office $user.Office -PostalCode $user.postalCode -State $user.State -StreetAddress $user.StreetAddress

            if ($userCreate) {
                $retryCount = 0
                do {
                    $userCheck2 = Get-AzureADUser -ObjectId $user.UserPrincipalName
                    Start-Sleep -Milliseconds 200
                    $retryCount++
                } until ($userCheck2 -or $retryCount -eq 10) # Retry for a maximum of 5 times

                if ($userCheck2) {
                    Set-MsolUserPassword -UserPrincipalName $user.userPrincipalName -NewPassword $user.Password # sets the password
                    Set-AzureADUserManager -ObjectId $user.userPrincipalName -RefObjectId $user.reportingManager # sets the manager
                    Set-AzureADUserExtension -ObjectId $user.userPrincipalName -ExtensionName ExtensionAttribute1 -ExtensionValue $user.customAttribute1
                    Set-AzureADUserExtension -ObjectId $user.userPrincipalName -ExtensionName ExtensionAttribute10 -ExtensionValue $user.CustomAttribute10
                    Set-AzureADUserExtension -ObjectId $user.userPrincipalName -ExtensionName ExtensionAttribute2 -ExtensionValue $user.CustomAttribute2
                    Set-AzureADUserExtension -ObjectId $user.userPrincipalName -ExtensionName ExtensionAttribute12 -ExtensionValue $user.CustomAttribute12
                    Write-Host -ForegroundColor Yellow "The following user '$($user.userPrincipalName)' has been successfully created."
                } else {
                    Write-Host -ForegroundColor Red "Failed to create user '$($user.UserPrincipalName)'. Maximum retries reached."
                }
            }
        } else {
            # Set Azure AD user extensions if the user already exists
            Set-MsolUserPassword -UserPrincipalName $user.userPrincipalName -NewPassword $user.Password # sets the password
            Set-AzureADUserManager -ObjectId $user.userPrincipalName -RefObjectId $user.reportingManager # sets the manager
            Set-AzureADUserExtension -ObjectId $user.userPrincipalName -ExtensionName ExtensionAttribute1 -ExtensionValue $user.customAttribute1
            Set-AzureADUserExtension -ObjectId $user.userPrincipalName -ExtensionName ExtensionAttribute10 -ExtensionValue $user.CustomAttribute10
            Set-AzureADUserExtension -ObjectId $user.userPrincipalName -ExtensionName ExtensionAttribute2 -ExtensionValue $user.CustomAttribute2
            Set-AzureADUserExtension -ObjectId $user.userPrincipalName -ExtensionName ExtensionAttribute12 -ExtensionValue $user.CustomAttribute12
            Write-Host -ForegroundColor Yellow "The following user '$($user.userPrincipalName)' has been successfully updated."
        }
    }
}
<#
        $results = [PSCustomObject]@{
        userPrincipalName         = $user.userPrincipalName
        AccountEnabled            = $AzureADUser.AccountEnabled
        RecipientTypeDetails      = $mailbox.RecipientTypeDetails
        RecipientType             = $mailbox.RecipientType
        jobTitle                  = $azureADUser.jobTitle
        StreetAddress             = $azureADUser.StreetAddress
        State                     = $azureADUser.State
        TelephoneNumber           = $azureADUser.TelephoneNumber
        PostalCode                = $AzureADUser.PostalCode
        City                      = $AzureADUser.City
        Department                = $AzureADUser.Department
        CompanyName               = $AzureADUser.CompanyName
        o365_groups               = $groups.DisplayName
        isLicensed                = $user.isLicensed
        Licenses                  = $user.Licenses
        msexchHideFromAddressBook = $mailbox.msexchHideFromAddressBook
        blockedCredential         = $user.blockedCredential
        EmailForwardingStatus     = $mailbox.EmailForwardingStatus
        ForwardingSmtpAddress     = $mailbox.ForwardingSmtpAddress
        ForwardingAddress         = $mailbox.ForwardingAddress
        TerminationDate           = $mailbox.TerminationDate
        }
        $results | Format-List *
#>

# This is a script that allows you to run a line and iterate through rows of a spreadsheet
