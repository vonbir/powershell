# Install required modules
$requiredModules = @("PSWindowsUpdate", "LSUClient")

foreach ($module in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Write-Host "Installing module: $module"
        Install-Module -Name $module -Force -AllowClobber | Import-Module
    }
}

# Activate Windows and set timezone
try {
    slmgr //B /ipk D8CXN-CJP9R-CQBCX-XTY27-46YPF  ##activates the win 10 enterprise product key silently
    Set-TimeZone "Eastern Standard Time" ##sometimes the timezone is set to central time

    # Define application names and associated arguments
    $applications = @{
        "ChromeSetup.exe"     = @('/silent', '/install')
        "teams.msix"          = @("/i D:\setup\teams.msix", '/qn', 'ALLUSERS=1')
        "systemupdate508.exe" = @('/VERYSILENT')
        "fclient709.exe"      = @('/quiet', '/norestart')
        "sophos.exe"          = @('--quiet')
        "zoom.msi"            = @("/i D:\setup\zoom.msi", '/qn', 'ZoomAutoUpdate=True', 'EnableSilentAutoUpdate=True', 'AlwaysCheckLatestVersion=true')
        "OfficeSetup.exe"     = @('/configure D:\setup\office365\configuration.xml')
    }

    # Start processes for each application
    foreach ($app in $applications) {
        $appName = $app.Key
        $arguments = $app.Value
        if (Test-Path $appName) {
            Start-Process $appName -ArgumentList $arguments -PassThru
        } else {
            Write-Host "Application not found: $appName" -ForegroundColor Yellow
        }
    }

    # Install Windows updates
    Install-WindowsUpdate -MicrosoftUpdate -UpdateType Software -AcceptAll -IgnoreReboot -Verbose

    # Install Lenovo updates
    $updates = Get-LSUpdate | Where-Object { $_.Installer.Unattended }
    $updates | Install-LSUpdate

    # Remove personal OneDrive from File Explorer
    New-PSDrive -Name HKCR -PSProvider registry -Root HKEY_CLASSES_ROOT -Scope Global
    Set-ItemProperty -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name System.IsPinnedToNameSpaceTree -Value $false

    # Reset execution policy
    Set-ExecutionPolicy Restricted -Force
} catch {
    Write-Host "An error occurred: $_" -ForegroundColor Red
    Write-Host "Please review the script and correct any issues." -ForegroundColor Red
}