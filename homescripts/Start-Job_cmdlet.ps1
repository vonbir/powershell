
# Using the Start-Job cmdlet improves the time it takes for data to be processed as compared to running it sequentially
# by running both processes at the same time in parallel in the background

# this is useful for when you are running multiple calls to API/Active Directory to process data

$outputPath1 = "C:\Scripts\StartJob\output1.txt"
$outputPath2 = "C:\Scripts\StartJob\output2.txt"

$job1 = Start-Job -ScriptBlock {
    $outputPath1 = "C:\Scripts\StartJob\output1.txt"
    Start-Sleep -Seconds 10
    Get-Random | Out-File -FilePath $outputPath1
}

$job2 = Start-Job -ScriptBlock {
    $outputPath2 = "C:\Scripts\StartJob\output2.txt"
    Start-Sleep -Seconds 15
    Get-Random | Out-File -FilePath $outputPath2
}

while (($job1.State -ne "Completed") -or ($job2.State -ne "Completed")) {
}

if ((Test-Path $outputPath1) -and (Test-Path $outputPath2)) {
    $output1 = Get-Content -Path $outputpath1
    $output2 = Get-Content -Path $outputpath2

    Write-Output "$output1 $output2"
}