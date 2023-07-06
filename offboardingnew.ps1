   
# Check if Active Directory module is installed
if (-not (Get-Module -Name ActiveDirectory -ListAvailable)) {
    Write-Host "Active Directory module not found. Installing the module..."
    Install-Module -Name RSAT-AD-PowerShell -Scope CurrentUser -Force
}

# Import Active Directory module
Import-Module -Name ActiveDirectory
   
# domain admin credentials
$UserName = Read-Host "Please enter your on-prem AD username" -AsSecureString
$Password = Read-Host "Please enter your AD password" -AsSecureString
$Cred = New-Object System.Management.Automation.PSCredential $UserName,$Password

# Ask for user to disable
$samname = Read-Host "ENTER USERNAME TO DISABLE HERE"

# Verify user exists, error handle
$User = $(try{get-aduser $samname -Properties *} catch {$null})

# current date
$date = get-date -Format yyyy/MM/dd

if ($User -ne $Null) {

    # disables the AD account
    Disable-ADAccount -Identity $samname -Credential $Cred
    Write-Output "--------------------------------------"
    Write-Output "Successfully disabled the user: $samname"

    # removes all AD groups
    Get-Aduser -Identity $samname -Properties MemberOf | foreach {

    _.MemberOf | Remove-AdGroupMember -Credential $Cred -Members $_.DistinguishedName -Confirm:$false 
    Write-Output "Successfully removed the user $samname from the AD groups"
    }
    
    # puts the current termination date
    Set-Aduser -Identity $samname -Replace @{extensionAttribute15="$date"} -Clear extensionAttribute2 -Credential $Cred
    Write-Output "The termination date set to: $date"
	    Write-Output "The license has also been removed."

    # hides the user from the global adddress book
	$exchHide =  Read-Host "Would you like to hide this user from the Address Lists? (Y/N)"
	
	if ($exchHide -eq "Y"){
    Set-Aduser -Identity $samname -Add @{msExchHideFromAddressLists=$true} -Credential $Cred
     Write-Output "The msExchHideFromAddressLists attribute has been set to: $($samname.msExchHideFromAddressLists)"
	}


   # displays the changes
    Get-Aduser -Identity $samname | Select-Object SamAccountName, Enabled, extensionAttribute15

} Else {
    Write-Host ""
    Write-Host "The user: '$samname' does not exist on the domain. Please try again.."
}