

Function Get-ADG {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$true)]
    [string]$upn
    )
Try{
$adUser = Get-AzureADUser -ObjectId $upn
$adGroup = Get-ADPrincipalGroupMembership -Identity $adUser.MailNickName
$adGroup | select Name
}
Catch{
Write-Host $Error[0] -ForegroundColor Red
Write-Host "Something went wrong, please try running the function again......." -ForegroundColor Yellow
}
}



Function Get-AADG {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$true)]
    [string]$upn
    )
Try{
$aadUser = get-azureaduser -SearchString $upn
$aadGroup = Get-AzureADUserMembership -ObjectId $aadUser.ObjectId
$aadGroup | select DisplayName, ObjectType, ObjectID
}
Catch{
Write-Host $Error[0] -ForegroundColor Red
Write-Host "Something went wrong, please try running the function again......." -ForegroundColor Yellow
}
}



Function Get-MailboxLogonTime {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$true)]
    [string]$email
    )
Try{
$aadUser = get-azureaduser -objectid $email
$stats = Get-MailboxStatistics -Identity $aadUser.MailNickName
$stats | select DisplayName, LastLogonTime, MailboxTypeDetail
}
Catch{
Write-Host $Error[0] -ForegroundColor Red
Write-Host "Something went wrong, please try running the function again......." -ForegroundColor Yellow
}
}


Function Verify-UserExist {
    [CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string]$UserPrincipalName
)

    try {
        $user = Get-MsolUser -SearchString $UserPrincipalName -ErrorAction Stop | Select-Object DisplayName, Title, Department, City, Office, StreetAddress, State, PhoneNumber, isLicensed, Licenses, ObjectID, userPrincipalName, UserType, BlockCredential

        $groups = Get-AzureADUserMembership -ObjectId $user.ObjectId | Where-Object {$_.ObjectType -eq "Group"}

       $user
       $groups | Select-Object ObjectId, DisplayName, Description | Format-Table

    }
    catch {
        Write-Host "Username does not exist, please try again." -ForegroundColor Yellow
    }
}

Function Verify-UserTerminated {
    [CmdletBinding()]
Param(
    [Parameter(Mandatory)]
    [string]$UserPrincipalName
)

Try{
$user = Get-MsolUser -SearchString $UserPrincipalName| foreach-object {
	[pscustomobject]@{
       blockedCredential = $_.BlockCredential
	   objectID = $_.ObjectID
	   UserPrincipalName = $_.UserPrincipalName
    }
}

$azureADUser = Get-AzureADUser -ObjectID $user.ObjectId | ForEach-Object {
    [pscustomobject]@{
        AccountEnabled = $_.AccountEnabled
        jobTitle = $_.jobTitle
        displayName = $_.displayName
		StreetAddress = $_.StreetAddress
		State = $_.State
		TelephoneNumber = $_.TelephoneNumber
		userPrincipalName = $_.userPrincipalName
		PostalCode = $_.PostalCode
		City = $_.City
		Department = $_.Department
		CompanyName = $_.CompanyName
    }
}

$groups = Get-AzureADUserMembership -ObjectId $user.ObjectId |
    Where-Object { $_.ObjectType -eq "Group" } |  ForEach-Object {
    [pscustomobject]@{
        ObjectID = $_.ObjectID
		DisplayName = $_.DisplayName
		Description = $_.Description
    }
	}

$mailbox = Get-Mailbox -Identity $UserPrincipalName | ForEach-Object {
    [pscustomobject]@{
        RecipientTypeDetails = $_.RecipientTypeDetails
		AccountDisabled = $_.AccountDisabled
		userPrincipalName = $_.userPrincipalName
		msexchHideFromAddressBook = $_.HiddenFromAddressListsEnabled
		TerminationDate = $_.customAttribute15
		ForwardingSmtpAddress = $_.ForwardingSmtpAddress
		EmailForwardingStatus = $_.DeliverToMailboxAndForward
    }
}

# Create a custom object with the desired properties
$results = [PSCustomObject]@{
    userPrincipalName = $user.userPrincipalName
    AccountEnabled = $AzureADUser.AccountEnabled
    RecipientTypeDetails = $mailbox.RecipientTypeDetails
	jobTitle = $azureADUser.jobTitle
	StreetAddress = $azureADUser.StreetAddress
	State = $azureADUser.State
	TelephoneNumber = $azureADUser.TelephoneNumber
	PostalCode = $AzureADUser.PostalCode
	City = $AzureADUser.City
	Department = $AzureADUser.Department
	CompanyName = $AzureADUser.CompanyName
	o365_groups = $groups.DisplayName 
	msexchHideFromAddressBook = $mailbox.msexchHideFromAddressBook
	blockedCredential = $user.blockedCredential
	EmailForwardingStatus = $mailbox.EmailForwardingStatus
	ForwardingSmtpAddress = $mailbox.ForwardingSmtpAddress
	TerminationDate = $mailbox.TerminationDate
}
$results | fl *
}
Catch{
Write-Host "The user does not exist. Please try again later.." -ForegroundColor Red -BackgroundColor Yellow
}
}




