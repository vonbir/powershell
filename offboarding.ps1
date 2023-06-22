
# connects to exchange online
Connect-ExchangeOnline

# connects to azure ad v1 (msonline module)
Connect-MsolService 

# connects to azure ad v2 (azuread module)
Connect-AzureAD 

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
    Set-Aduser -Identity $samname -Replace @{extensionAttribute15="$date"} -Credential $Cred
    Write-Output "The termination date set to: $date"

    # removes e3 license 
    set-aduser -Identity $samname -Clear extensionAttribute2 -Credential $Cred
    Write-Output "The license has been removed."

    # hides the user from the global adddress book
    Set-Aduser -Identity $samname -Add @{msExchHideFromAddressLists=$true} -Credential $Cred
     Write-Output "The msExchHideFromAddressLists attribute has been set to: $($samname.msExchHideFromAddressLists)"

    # initiate sign-out of all office 365 sessions by revoking the refresh tokens issue to applications for a use
    Get-AzureADUser -SearchString $samname | revoke-azureaduserallrefreshtoken

    # blocks sign-in from this o365 account
    Set-MsolUser -UserPrincipalName $samname -BlockCredential $true


    # specifies the user that will be removed from these groups
    $upn = get-aduser -Identity $samname | select -Property *

    # looks through all the o365 groups (only DLs & Security groups) (not using it for now)
    #$groups = get-msolgroup -all | where {($_.GroupType -notlike "MailEnabledSecurity") -and ($_.DisplayName -notlike "*Backup*")} | select -First 1
    
    # gets all the distribution groups within the tenant
    $dgs = Get-DistributionGroup  | where Name -like "Signature Manager*" | select -Property *

    # gets the mailbox properties for the user
    $mail = Get-Mailbox -Identity $samname

    foreach($dg in $dgs)

    # gets the distribution group members of each distribution list

    {

    $DGMs = Get-DistributionGroupMember -identity $dg.DistinguishedName

        foreach ($dgm in $DGMs)

        { if ($dgm.name -eq $mail.Name){

        Remove-DistributionGroupMember $dg.Name -Member $mail.UserPrincipalName -confirm:$false

        } 
        }
        }

    Write-Output "Converting the user's regular user mailbox to 'SHARED'......."

    # converts the regular user mailbox to shared 
    Set-Mailbox -Identity $samname -Type Shared

    Write-Output "Successfully converted the user's mailbox to 'SHARED'."

    # displays the changes
    Get-Aduser -Identity $samname | Select-Object SamAccountName, Enabled, extensionAttribute15

} Else {
    Write-Host ""
    Write-Host "The user: '$samname' does not exist on the domain. Please try again.."
}