
# Check if Active Directory module is installed
if (-not (Get-Module -Name ActiveDirectory -ListAvailable)) {
    Write-Host "Active Directory module not found. Installing the module..."
    Install-Module -Name RSAT-AD-PowerShell -Scope CurrentUser -Force
}

# Import Active Directory module
Import-Module -Name ActiveDirectory

# domain admin credentials
[string]$adminuser = Read-Host "Please enter your on-prem AD username"
$adminpass = Read-Host "Please enter your on-prem AD password" -AsSecureString 
$Cred = New-Object System.Management.Automation.PSCredential $adminuser,$adminpass

# Prompt for user details
[string]$firstName = Read-Host "Enter first name"
[string]$lastName = Read-Host "Enter last name"
[string]$username = Read-Host "Enter username"
$userpass= Read-Host "Enter password" -AsSecureString
[string]$JobTitle = Read-Host "Enter the user's Job Title"
[string]$Department = Read-Host "Enter the user's Department"
#[string]$Manager = Read-Host "Enter the user's Reporting Manager"
[string]$extensionAttribute1 = Read-Host "Enter extension attribute 1 value (Company Initials)"
[string]$extensionAttribute2 = Read-Host "Enter extension attribute 2 value (License Type, E3/F3)"
[string]$extensionAttribute10 = Read-Host "Enter extension attribute 10 value (Hiring Date, yyyy/MM/dd)"
[string]$extensionAttribute14 = Read-Host "Enter extension attribute 14 value (AADSyncTrue or not?)"
[string]$containerInput = Read-Host "Enter the container division for this user (GG,FG,THR,GBS,HT,DD)"

# Set container DN based on user's input
if ($containerInput -eq "GG") {
    $containerDN = "OU=Users,OU=GreatGulf,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
    $useremail = "$username@greatgulf.com"
}
        elseif ($containerInput -eq "FG") {
            $containerDN = "OU=Users,OU=FirstGulf,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
            $useremail = "$($firstName.Substring(0,1))$lastName@firstgulf.com"
        }
        elseif ($containerInput -eq "THR") {
            $containerDN = "OU=Users,OU=TuckerHiRise,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
            $useremail = "$username@tuckerhirise.com"
        }
        elseif ($containerInput -eq "GBS") {
            $containerDN = "OU=Users,OU=GreatBuilderSolutions,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
            $useremail = "$username@greatbuildersolutions.com"
        }
        elseif ($containerInput -eq "HT") {
            $containerDN = "OU=Users,OU=BrockportHS,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
            $useremail = "$username@hometechnology.com"
        }
        elseif ($containerInput -eq "DD") {
            $containerDN = "OU=Users,OU=HomeCAD,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
            $useremail = "$username@draftdesign.ca"
        }
else {
    Write-Host "Invalid container type. Exiting script."
    exit
    }

# Create user object
New-ADUser -GivenName $firstName -Surname $lastName -SamAccountName $username -UserPrincipalName $useremail -Name "$firstName $lastName" -Enabled $true -AccountPassword $userpass -Path $containerDN -Credential $Cred -EmailAddress $useremail -Description $jobTitle

$user = get-aduser -Identity $username -Properties *

# Set extension attributes
if ($extensionAttribute14 -ne "AADSyncTrue"){

Set-ADUser -Identity $user.DistinguishedName -Add @{extensionAttribute1 = $extensionAttribute1; extensionAttribute2 = $extensionAttribute2; extensionAttribute10 = $extensionAttribute10} -Clear 'extensionAttribute14' -Credential $cred -Title $JobTitle -Department $Department `
-StreetAddress "351 King Street East, 13th Floor, Suite 1300" -City "Toronto" -PostalCode "M5A 0L6" -Country CA
}

else {
Set-ADUser -Identity $user.DistinguishedName -Add @{extensionAttribute1 = $extensionAttribute1; extensionAttribute2 = $extensionAttribute2; extensionAttribute10 = $extensionAttribute10; extensionAttribute14 = $extensionAttribute14} -Credential $Cred -Title $JobTitle -Department $Department `
-StreetAddress "351 King Street East, 13th Floor, Suite 1300" -City "Toronto" -PostalCode "M5A 0L6" -Country CA
}

# Output the created user details
Write-Host -ForegroundColor Yellow -BackgroundColor Blue "The user has been created successfully!"
Write-Host -ForegroundColor Yellow -BackgroundColor DarkRed "Username: $username"
Write-Host -ForegroundColor Yellow -BackgroundColor DarkRed "Extension Attribute 1: $extensionAttribute1"
Write-Host -ForegroundColor Yellow -BackgroundColor DarkRed "Extension Attribute 2: $extensionAttribute2"
Write-Host -ForegroundColor Yellow -BackgroundColor DarkRed "Extension Attribute 10: $extensionAttribute10"
Write-Host -ForegroundColor Yellow -BackgroundColor DarkRed "Extension Attribute 14: $extensionAttribute14"
