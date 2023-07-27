$creds = Get-Credential

Invoke-Command -ComputerName test1 -Credential $creds -ScriptBlock { 
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    choco feature enable -y allowGlobalConfirmation
 }



 Invoke-Command -ComputerName test1 -Credential $creds -ScriptBlock { 
 
choco install microsoft-teams.install --version=1.2.00.8864

 }


$credential = Get-Credential

$psdrive = @{
    Name = "PSDrive"
    PSProvider = "FileSystem"
    Root = "\\gbsfs01\GBS_apps\ISO"
    Credential = $credential
}


Invoke-Command -ComputerName test1 -Credential $credential -ScriptBlock {

    New-PSDrive @using:psdrive
    Start-Process -Wait -FilePath \\gbsfs01\GBS_apps\ISO\ChromeSetup.exe -ArgumentList '/silent' , '/install' -PassThru
    powershell.exe \\gbsfs01\gbs_apps\ISO\deploy\Deploy-MicrosoftTeams.ps1 -DeploymentType "Install" -DeployMode "Silent"
    Start-Process MsiExec.exe -ArgumentList '/i \\gbsfs01\GBS_apps\ISO\ZoomInstallerFull.msi' , '/qn' -PassThru
    Start-Process -Wait -FilePath \\gbsfs01\GBS_apps\ISO\system_update_5.07.0131 -ArgumentList '/VERYSILENT' -PassThru -NoNewWindow
    Start-Process -Wait -FilePath \\gbsfs01\GBS_apps\ISO\FortiClientSetup_6.2.9_x64.exe -ArgumentList '/quiet' ,'/passive', '/norestart' -PassThru -NoNewWindow
    Start-Process -Wait -FilePath \\gbsfs01\GBS_apps\ISO\SophosSetup.exe -\\\ArgumentList '--quiet' -PassThru -NoNewWindow

    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-Module PSWindowsUpdate -Force
    Set-ExecutionPolicy -ExecutionPolicy Bypass

    Invoke-WUJob -Script { import-module PSWindowsUpdate; Install-WindowsUpdate -AcceptAll -Install -Verbose -AutoReboot | Out-File C:\PSWindowsUpdate.log } -Confirm:$false -RunNow -ErrorAction Ignore
    
    Install-Module LSUClient -Force
    Get-LSUpdate | where {$_.Installer.Unattended} | Install-LSUpdate -Verbose

    Write-Output "Installation is done."

} 



 