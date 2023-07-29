
# Connect to Office365 services 

$requiredModules = @("AzureAD", "MSOnline", "ExchangeOnlineManagement")

foreach ($module in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module -ErrorAction SilentlyContinue)) {
        Write-Host "Installing module: $module"
        Install-Module -Name $module -Force -AllowClobber
    }
}

# Connect to Azure AD
if (-not (Get-AzureADCurrentSessionInfo -ErrorAction SilentlyContinue)) {
    Write-Host "Connecting to Azure AD"
    Connect-AzureAD
} else {
    Write-Host "Already connected to Azure AD..."
}

# Connect to Azure AD using the MSOnline module
if (-not (Get-MsolAccountSku -ErrorAction SilentlyContinue)) {
    Write-Host "Connecting to Azure AD using MSOnline module"
    Connect-MsolService
} else {
    Write-Host "Already connected to the MSOnline module...."
}

# Connect to Exchange Online
if (-not (Get-PSSession -ErrorAction SilentlyContinue | Select-Object -Property Name -First 1 | Where-Object { $_.Name -like "ExchangeOnline*" })) {
    Write-Host "Connecting to Exchange Online"
    Connect-ExchangeOnline
} else {
    Write-Host "Already connected to Exchange Online...."
}

Param(
    [Parameter(Mandatory)]
    [string]$UserPrincipalName
)

$user = Get-MsolUser -UserPrincipalName $UserPrincipalName| foreach-object {
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

$results