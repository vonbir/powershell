
Get-Date

Get-Date -DisplayHint Date

# I think this one is only supported in the latest version of PowerShell
Get-Date -AsUTC

$Date = Get-Date

# uses the .ToUniversalTime method to convert it instead (dot method)
$Date.ToUniversalTime()
(Get-Date).ToUniversalTime()

# custom format for the Get-Date cmdlet, K is the difference to the UTC time
$DateF = Get-Date -Format "yyyy-MM-dd HH:mm dddd K"

$Date.Gettype() # this is a DateTime object
$DateF.GetType() # this is a String object

# this is the hard way of formatting the date by using variable wrappers
Write-Output "$($Date.Year)-$($Date.Month)-$($Date.Day)"

#another formatting method, the UFormat parameter
Get-Date -UFormat "%Y-%m-%d"

#this is a way of creating your own date for time comparison reasons/etc..
Get-Date -Year 2022 -Month 12 -Day 2 -Hour 13 -Minute 5 -Second 30

# gets the day of the year of that (get-date) output
(Get-Date).DayOfYear
(Get-Date -Year 2022 -Month 12 -Day 2 -Hour 13 -Minute 5 -Second 30).DayOfYear
(Get-Date -Year 2022 -Month 12 -Day 2 -Hour 13 -Minute 5 -Second 30).DayOfWeek

# more examples
Get-Date -Format "yyyy-MM-dd THH-mm-ss"