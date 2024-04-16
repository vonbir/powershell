
#This scriptblock is to run a scheduled task
$trigger = New-ScheduledTaskTrigger -At 3pm -Daily
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File "C:\Scripts\TestSpaceX.ps1""
$settings = New-ScheduledTaskSettingsSet
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Test SpaceX" -Description "Tests connection with SpaceX.com" -Settings $settings

# Gets the Scheduled task information such as the LastRunTime/NextRunTime/TaskName/TaskPath/NumberofMissedRuns
Get-ScheduledTask -TaskName "PushLaunch" | Get-ScheduledTaskInfo

# Removes the scheduled task (becareful when dealing with wildcards on this one)
Unregister-ScheduledTask -TaskName "PushLaunch" -Confirm:$false
# to verify
Get-ScheduledTask -TaskName "PushLaunch"

#This scriptblock is to run a scheduled job (similar to tasks but it allows you to run a script/command in scheduled intervals and has more advanced options such as running a job even while the computer is in a diff. state)
$trigger = New-JobTrigger -Daily -At 3pm
$Scriptblock = { C:\Scripts\TestSpaceX.ps1 }
Register-ScheduledJob -Name "TestSpaceX Job" -ScriptBlock $Scriptblock -Trigger $trigger

#to verify
Get-ScheduledJob -Name "TestSpaceX*" | Get-JobTrigger

#Removes the scheduled job
Unregister-ScheduledJob -Name "TestSpaceX Job"

<#
    WHAT'S THE DIFFERENCE BETWEEN SCHEDULED TASK AND JOB?

    Scheduled Task is just a Windows thing and PowerShell can control it in the same way it (PowerShell) can control many other Windows things.

    Scheduled Job is, in the other hand, mostly PowerShell thing. Namely, scheduled job is some PowerShell code scheduled for execution in a "Windows Task Scheduler" manner and executed within PowerShell environment (naturally).

    So, an activity run as a Scheduled Task is anything you can run from command prompt (eg. .EXE, .BAT, .COM, .CMD etc. - nothing PowerShell-ish, unless you decide to start powershell.exe and give it some script name to execute. Yet, you can control all of that from PowerShell.

    On the other hand, Scheduled Job is exclusively PowerShell code (be it script block or script file) that PowerShell registers with Windows Task Scheduler, and Windows Task Scheduler knows how to activate it. Method of repetitive activation is in both cases the same ("triggers").

    So, Powershell Scheduled Task is a Windows thing (controllable also from PowerShell), while PowerShell Scheduled Job is a exclusively PowerShell thing.
#>









