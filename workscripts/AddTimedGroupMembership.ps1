
$domain = "testdomain.local"
$username = "employee1"
$groupName = "webadmin"

Get-ADOptionalFeature -Filter { Name -like "Privileged*" }

<#
    Privileged access management (PAM) has to do with the processes and technologies necessary for securing privileged accounts.
    It is a subset of IAM that allows you to control and monitor the activity of privileged users
    (who have access above and beyond standard users) once they are logged into the system.

    Do note that this feature is irreversible in certain OUs, please advise.
#>
Enable-ADOptionalFeature -Identity "Privileged Access Management Feature" -Scope ForestOrConfigurationSet -Target $domain

Get-ADGroupMember $groupName -Server $domain

$time = New-TimeSpan -Minutes 1

# to pull the execution time
Get-Date
Add-ADGroupMember -Identity $groupName -Members $username -MemberTimeToLive $time -Server $domain

# to verify the changes after the assigned timespan which is a minute
Get-Date
Get-ADGroupMember $groupName -Server $domain


