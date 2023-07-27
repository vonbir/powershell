
if ($env:TERM_PROGRAM -eq "vscode") {
  Set-PSReadLineKeyHandler -Chord 'Ctrl+w' -Function BackwardKillWord
}

$PSDefaultParameterValues['Get-ADUser:Properties'] = @(
    'DisplayName',
    'Description',
    'EmailAddress',
    'LockedOut',
    'Manager',
    'MobilePhone',
    'telephoneNumber',
    'PasswordLastSet',
    'PasswordExpired',
    'ProxyAddresses',
    'Title',
    'wwWHomePage'
)

$PSDefaultParameterValues['Export-Csv:NoTypeInformation'] = $true

function Start-Stopwatch {
    $script:StopWatch = [System.Diagnostics.Stopwatch]::StartNew()
    write-output "Stopwatch started at $(get-date). Use stop-stopwatch or esw to stop."
}
function Stop-Stopwatch {
    $script:StopWatch.Stop()
    write-output "Stopwatch stopped at $(get-date). Elapsed time is $($script:StopWatch.elapsed.tostring())"
    write-output $script:Stopwatch.Elapsed | ft
}
function Get-Stopwatch {
    If ($script:Stopwatch.IsRunning) {$state = "running"}Else{$state = "stopped"}
    write-output "Stopwatch is currently $state. Elapsed time is $($script:StopWatch.elapsed.tostring())"
    write-output $script:Stopwatch.Elapsed | ft
}
function Continue-Stopwatch {
    $script:StopWatch.Start()
    write-output "Stopwatch continuing from $($script:StopWatch.elapsed.tostring())"
}
