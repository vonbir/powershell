

# installs PowerShell 7

Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI"


#Displays the free space of C: drive and also changing the property name, selecting freespace, and changing it to gigabytes as integer

Get-WmiObject win32_logicaldisk -Filter "DeviceID='c:'" | Select-Object @{n = 'freegb' ; e = { $_.freespace / 1gb -as [int] } }


#Adds user into the domain

Add-Computer -ComputerName test01 -DomainName WORKGROUP -Credential Administrator -Restart


#Displays the baseboard manufacturer,model, and serial number (hit Ctrl+Space to see all Win32 class names)

Get-CimInstance Win32_BaseBoard

#runs the powershell as admin

$isAdmin = [System.Security.Principal.WindowsPrincipal]::new(
    [System.Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole('Administrators')

if (-not $isAdmin) {
    $params = @{
        FilePath     = 'powershell' # or pwsh if Core
        Verb         = 'RunAs'
        ArgumentList = @(
            "-NoExit"
            "-ExecutionPolicy ByPass"
            "-File `"$PSCommandPath`""
        )
    }
    Start-Process @params
    Exit
}





