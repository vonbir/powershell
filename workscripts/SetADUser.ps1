
# defines the variables
$username = 'employee1'
$domain = 'testdomain'

# pulls the property info of an ad user
Get-ADUser -Identity $username -Server $domain -Properties EmployeeID, Description, ProxyAddresses

# creates a hashtable for properties to be passed unto the set-aduser cmdlet
$propertyHash = @{
    EmployeeID     = '1234'
    Description    = 'Test'
    ProxyAddresses = 'SMTP:employee1@greatgulf.com'
}

# uses the hashtable to make the parameter changes
Set-ADUser -Identity $username -Add @propertyHash -Server $domain

# to verify changes
Get-ADUser -Identity $username -Server $domain -Properties EmployeeID, Description, ProxyAddresses

# DO NOTE THAT THE PROPERTIES HAVE TO MATCH FOR ANY MODIFICATIONS TO BE MADE OR ELSE AN ERROR OCCURS


````````````````````````````````````````````````````````````````````````````````


# TO FIX THE ERROR THAT OCCURS, YOU CAN GO AHEAD AND USE THE 'REPLACE' property which replaces the values instead.

$propertyHash = @{
    EmployeeID     = '12345'
    Description    = 'Testing'
    ProxyAddresses = @('SMTP:employee1@greatgulf.com', 'SMTP:employe11@test.greatgulf.com')
}
Set-ADUser -Identity $username -Replace @propertyHash -Server $domain

Get-ADUser -Identity $username -Server $domain -Properties EmployeeID, Description, ProxyAddresses


````````````````````````````````````````````````````````````````````````````````

# NEXT PROPERTY IS 'REMOVE', this will remove all properties in the passed hashtable values

$ADUser = Get-ADUser -Identity $username -Server $domain -Properties EmployeeID, Description, ProxyAddresses

$ADUser.ProxyAddresses

$propertyHash = @{
    ProxyAddresses = $($ADUser.ProxyAddresses -like "*@test.greatgulf.com")
}

Set-ADUser -Identity $Username -Remove $propertyHash -Server $domain

$ADUser = Get-ADUser -Identity $username -Server $domain -Properties EmployeeID, Description, ProxyAddresses


`````````````````````````````````````````````````````````````````````````````````

# This will use the -Replace parameter with the -notlike expression

$ADUser = Get-ADUser -Identity $username -Server $domain -Properties EmployeeID, Description, ProxyAddresses

$ADUser.ProxyAddresses

$propertyHash = @{
    ProxyAddresses = $($ADUser.ProxyAddresses -notlike "*@test.greatgulf.com")
}

Set-ADUser -Identity $Username -Replace $propertyHash -Server $domain

$ADUser = Get-ADUser -Identity $username -Server $domain -Properties EmployeeID, Description, ProxyAddresses





