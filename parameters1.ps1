
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

