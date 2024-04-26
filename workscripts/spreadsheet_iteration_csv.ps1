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

<<<<<<< HEAD
        $userCheck = Get-MsolUser -UserPrincipalName $user.userPrincipalName
=======
    $userCheck = Get-MsolUser -UserPrincipalName $user.userPrincipalName

    if($userCheck -eq $Null){

    $userCreated = New-MsolUser -UserPrincipalName $user.userPrincipalName

    if($userCreated){
        Set-AzureADUserExtension -ObjectId $user.EmailAddress -ExtensionName ExtensionAttribute1 -ExtensionValue "TM"
        Write-Host -ForegroundColor Yellow "Successfully set the customAttribute1 to '$($user.customAttribute1)'"
        Set-AzureADUserExtension -ObjectId $user -ExtensionName ExtensionAttribute10 -ExtensionValue $user.CustomAttribute10
        Write-Host -ForegroundColor Yellow "Successfully set the customAttribute10 to '$($user.customAttribute10)'"
        Set-AzureADUserExtension -ObjectId $user -ExtensionName ExtensionAttribute2 -ExtensionValue $user.CustomAttribute2
        Write-Host -ForegroundColor Yellow "Successfully set the customAttribute2 to '$($user.customAttribute2)'"
        Write-Host -ForegroundColor Yellow "AzureAD attributes have been successfully set.."
    }
    else{
        Write-Host "Something went wrong in the process of creating the user, lease try again later.."
    }
    }
    else {
        Set-AzureADUserExtension -ObjectId $user.EmailAddress -ExtensionName ExtensionAttribute1 -ExtensionValue "TM"
        Write-Host -ForegroundColor Yellow "Successfully set the customAttribute1 to '$($user.customAttribute1)'"
        Set-AzureADUserExtension -ObjectId $user -ExtensionName ExtensionAttribute10 -ExtensionValue $user.CustomAttribute10
        Write-Host -ForegroundColor Yellow "Successfully set the customAttribute10 to '$($user.customAttribute10)'"
        Set-AzureADUserExtension -ObjectId $user -ExtensionName ExtensionAttribute2 -ExtensionValue $user.CustomAttribute2
        Write-Host -ForegroundColor Yellow "Successfully set the customAttribute2 to '$($user.customAttribute2)'"
        Write-Host -ForegroundColor Yellow "AzureAD attributes have been successfully set.."
    }
>>>>>>> a85b8a5f86c9534ce23b12fb8e4814392063ffcc

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
<<<<<<< HEAD
=======
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
>>>>>>> a85b8a5f86c9534ce23b12fb8e4814392063ffcc
