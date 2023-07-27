
# You don't actually have to define parameters
# Arguments past to a script are captured into default variables which in this is $args
# Prefer to use named parameters

Write-Host "Number of arguments was :" ($args.Length)
Write-Output "and they were:"
foreach ($arg in $args) {
Write-Output $arg
}

.\parameters1.ps1 hello world this is a test

# 3 Types of Parameters which include:

# Switch Parameter

Get-ChildItem -Recurse

# Option Parameter

Get-ChildItem -Filter *.txt

# Positional Parameter (Arguments)

Get-ChildItem *.txt


# using multiple parameters,

# you can explicitly define the parameter and position by the example below:

Param([Parameter(Mandatory=$true,Position=2)][String]$Name,
[Parameter(Mandatory=$true,Position=1)][String]$Greeting)
Write-Host $Greeting $Name

.\parameters1.ps1 hello world



```````````````````````````

$array = "ali.reisman", "paul.chin", "cheryl.tolentino", "rommuel.gardon", "marilyn.mazzotta", "alex.heming", "lauren.west", "tehmina.athar"
$logon = Import-Csv -Delimiter ';' -Path "C:\Users\brylle.purificacion\Downloads\Web50repNoAdLogonLast60d.csv"
$customArray = @()

# Iterate over each element in the original array
foreach ($item in $array) {
    # Create a custom object with the 'username' property
    $customObject = [PSCustomObject]@{
        username = $item
    }

    # Add the custom object to the new array
    $customArray += $customObject
}

# iterates through the customArray and filters based on the username property of another array named '$logon'

# the variable '$logon' is an array that contains multiple propreties that we plan to match.

foreach ($object in $customArray) {
    $matchingItem = $logon | Where-Object { $_.username -eq $object.username }

    if ($matchingItem) {
        Write-Host "Match found for item '$($object.username)':"
        Write-Host "LastLogon: $($matchingItem.lastlogon)"
        Write-Host
    }
}
