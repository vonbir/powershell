






Install-Module PSWindowsUpdate -Force
Install-Module LSUClient -Force 

Install-WindowsUpdate -AcceptAll -ForceInstall -IgnoreReboot 

Get-LSUpdate | Install-LSUpdate -Verbose

Copy-Item \\gbsfs01\GBS_apps\bry\Installers\Installers -Destination C:\ -Force -Recurse

$path = get-childitem -Path "C:\Installers\*"


foreach ($item in $path)

{ 
    Start-Process -Wait -FilePath C:\Installers\ChromeSetup.exe -ArgumentList '/silent' , '/install' -PassThru
    Start-Process -Wait -FilePath C:\Installers\TeamsSetup_c_w_.exe -ArgumentList '/silent' -PassThru
    Start-Process -Wait -FilePath C:\Installers\ZoomInstallerFull.msi -ArgumentList '/qn' , '/install' -PassThru
    Start-Process -Wait -FilePath C:\Installers\system_update_5.07.0131 -ArgumentList '/VERYSILENT' -PassThru -NoNewWindow

    break
    Write-Output "---------------------------------------"
    Write-Output "Installation has finished. Please exit."
} 

Remove-Item -Path "C:\Installers" -Recurse
Set-ExecutionPolicy -ExecutionPolicy Restricted 
foreach ($item in $path)

{ 
    Start-Process -Wait -FilePath C:\Installers\ChromeSetup.exe -ArgumentList '/silent' , '/install' -PassThru
    Start-Process -Wait -FilePath C:\Installers\TeamsSetup_c_w_.exe -ArgumentList '/silent' -PassThru
    Start-Process -Wait -FilePath C:\Installers\ZoomInstallerFull.exe -ArgumentList '/silent' , '/install' -PassThru
    Start-Process -Wait -FilePath C:\Installers\system_update_5.07.0140 -ArgumentList '/VERYSILENT' -PassThru -NoNewWindow

    Write-Output "---------------------------------------"
    Write-Output "Installation has finished. Please exit."
} 

Remove-Item -Path "C:\Installers" -Recurse

