
$group1 = "Accounting"
$group2 = "Marketing"
$domain = "test.local"

# lists all the group members of the AD group mentioned recursively.
Get-ADGroupMember -Identity $group1 -Server $domain -Recursive

# does not guarantee that it will list all nested members within this group, the recursive switch parameter is a better option to pull the users.
Get-ADGroupMember -Identity $group2 -Server $domain

$groupName = "Sales"
$results = @()

$results += Get-ADGroupMember -Identity $groupName -Sever $domain

while (($results | Where-Object { $_.ObjectClass -eq "group" } -NE $null )) {
    foreach ($entry in $results) {
        if ($entry.objectClass -eq "group") {
            $results += Get-ADGroupMember -Identity $entry.Name -Server $domain
            $results = @($results | Where-Object { $_.ObjectGuid -ne $entry.ObjectGuid })
        }
    }
}
$results = $results | Select-Object -Unique



