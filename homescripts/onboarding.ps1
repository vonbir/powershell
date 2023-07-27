
# Check if Active Directory module is installed
if (-not (Get-Module -Name ActiveDirectory -ListAvailable)) {
    Write-Host "Active Directory module not found. Installing the module..."
    Install-Module -Name RSAT-AD-PowerShell -Scope CurrentUser -Force
}

# Import Active Directory module
Import-Module -Name ActiveDirectory

# domain admin credentials

if (-not ($adminuser)){
[string]$adminuser = Read-Host "Please enter your on-prem AD username (\GREATGULF\string)" 
$adminpass = Read-Host "Please enter your on-prem AD password" -AsSecureString 
$Cred = New-Object System.Management.Automation.PSCredential $adminuser,$adminpass
}

Write-Host
Write-Host "You are currently logged in as: " -NoNewline;Write-Host "$adminuser" -ForegroundColor Yellow
Write-Host

# Prompt for user details

Try {
$splatADUser =  [ordered]@{
    GivenName = Read-Host "Enter the first name of the user to create"
	Surname = Read-Host "Enter the last name"
	AccountPassword = Read-Host "Enter the password" -AsSecureString
	Description = Read-Host "Enter the user's Job Title"
	Department = Read-Host "Enter the user's Department"
	#Manager = Read-Host "Enter the user's Reporting Manager"
	Enabled = $true
}

$SamAccountName = $($splatADUser.GivenName) + "." + $($splatADUser.Surname)
$Name = $($splatADUser.GivenName) + " " + $($splatADUser.Surname)

[string]$containerInput = Read-Host ("Enter the container division for this user (GG,FG,THR,GBS,HT,DD)")
        $containerinput = $containerInput.ToUpper()
        $extensionAttribute1 = $containerInput
[string]$extensionAttribute2 = Read-Host "Enter extension attribute 2 value (License Type, E3/F3)"
[string]$extensionAttribute10 = Read-Host "Enter extension attribute 10 value (Hiring date, yyyy/MM/dd)"
[string]$extensionAttribute14 = Read-Host "Enter extension attribute 14 value (AADSyncTrue or not?)"

# Set container DN based on user's input

if ($containerInput -match "GG") {
    $containerDN = "OU=Users,OU=GreatGulf,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
    $useremail = "$SamAccountName@greatgulf.com"
}
        elseif ($containerInput -eq "FG") {
            $containerDN = "OU=Users,OU=FirstGulf,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
            $useremail = "$($firstName.Substring(0,1))$lastName@firstgulf.com"
        }
        elseif ($containerInput  -eq "THR") {
            $containerDN = "OU=Users,OU=TuckerHiRise,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
            $useremail = "$SamAccountName@tuckerhirise.com"
        }
        elseif ($containerInput -eq "GBS") {
            $containerDN = "OU=Users,OU=GreatBuilderSolutions,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
            $useremail = "$SamAccountName@greatbuildersolutions.com"
        }
        elseif ($containerInput -eq "HT") {
            $containerDN = "OU=Users,OU=BrockportHS,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
            $useremail = "$SamAccountName@hometechnology.com"
        }
        elseif ($containerInput -eq "DD") {
            $containerDN = "OU=Users,OU=HomeCAD,OU=Sites and Divisions,OU=Great Gulf Group,DC=greatgulf,DC=biz"
            $useremail = "$SamAccountName@draftdesign.ca"
        }

# Create user object
New-ADUser $SamAccountName @splatADUser -Path $containerDN -Credential $Cred -EmailAddress $useremail -UserPrincipalName $useremail -SamAccountName $SamAccountName -DisplayName $Name

$user = get-aduser -Identity $SamAccountName -Properties *

# Set extension attributes
if ($extensionAttribute14 -eq "AADSyncTrue"){
Set-ADUser -Identity $user.DistinguishedName -Add @{extensionAttribute1 = $extensionAttribute1; extensionAttribute2 = $extensionAttribute2; extensionAttribute10 = $extensionAttribute10; extensionAttribute14 = $extensionAttribute14} -Credential $Cred -Title $splatADUser.Description -Department $splatADUser.Department `
-StreetAddress "351 King Street East, 13th Floor, Suite 1300" -City "Toronto" -PostalCode "M5A 0L6" -Country CA
}
else {
Set-ADUser -Identity $user.DistinguishedName -Add @{extensionAttribute1 = $extensionAttribute1; extensionAttribute10 = $extensionAttribute10; extensionAttribute14 = $extensionAttribute14} -Clear extensionAttribute2 -Credential $cred -Title $splatADUser.Description -Department $splatADUser.Department `
-StreetAddress "351 King Street East, 13th Floor, Suite 1300" -City "Toronto" -PostalCode "M5A 0L6" -Country CA
}

# Output the created user details
Write-Host
Write-Host -ForegroundColor Yellow "The user has been created successfully!"
Write-Host
Write-Host "Username: " -NoNewline;Write-Host -ForegroundColor Yellow "Username: $SamAccountName"
Write-Host "ExtensionAttribute1: " -NoNewline;Write-Host -ForegroundColor Yellow "$extensionAttribute1"
Write-Host "ExtensionAttribute2: " -NoNewline;Write-Host -ForegroundColor Yellow "$extensionAttribute2"
Write-Host "ExtensionAttribute10: " -NoNewline;Write-Host -ForegroundColor Yellow "$extensionAttribute10"
Write-Host "ExtensionAttribute14: " -NoNewline;Write-Host -ForegroundColor Yellow "$extensionAttribute14"
Write-Host
}
Catch {
 Write-Host
 Write-Host "[ERROR]`t Oops, something went wrong: $($_.Exception.Message)`r`n" -ForegroundColor Red
 Write-Host
 }



