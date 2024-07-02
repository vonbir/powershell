Function Run-MFACycle {

    <#
        .DESCRIPTION

        The Managed Folder Assistant (MFA) is an Exchange Mailbox Assistant that applies and processes the message retention settings
        that are configured in retention policies.

        Exchange Online Archiving can take up to 24 hours to begin archiving email out of the primary mailbox after it is enabled for a user in Microsoft 365.
        Other cause could be if the size of the mailbox in Exchange Online is less than 10 megabytes (MB). The retention policy runs automatically one time every
        seven days for mailboxes that are larger than 10 MB. However, the retention policy doesn’t automatically run for mailboxes that are smaller than 10 MB.

        In some cases, you want to force the Managed Folder Assistant run immediately. MFA does not run immediately and will take some time to process.
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [string]$email
    )


    $ErrorActionPreference = "SilentlyContinue"

    # Check if modules are installed and install if necessary
    $requiredModules = @("ExchangeOnlineManagement")
    $ErrorActionPreference = 'SilentlyContinue'

    foreach ($module in $requiredModules) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            Write-Host "Installing module: $module"
            Install-Module -Name $module -Force -AllowClobber
        }
    }

    # Connect to Exchange Online
    if (-not (Get-PSSession | Select-Object -Property Name -First 1 | Where-Object { $_.Name -eq "ExchangeOnline*" })) {
        Write-Host "Connecting to Exchange Online..."
        Connect-ExchangeOnline
        Write-Host "Successfully connected to Exchange Online." -ForegroundColor Yellow
    } else {
        Write-Host "Successfully connected to Exchange Online." -ForegroundColor Yellow
    }

    # This runs the Start-ManagedFolderAssistant command to force the MFA runs on a single mailbox

    Write-Host
    Write-Host "Running the ManagedFolderAssistant cmdlet for the user: " -NoNewline; Write-Host "$email" -ForegroundColor Yellow
    Write-Host
    Write-Host "--------------"
    Write-Host "----------------------------------"
    Write-Host "---------------------------------------------"
    Write-Host "-------------------------------------------------------"
    Start-ManagedFolderAssistant -Identity $email -Verbose
    Write-Host "-------------------------------------------------------"
    Write-Host "---------------------------------------------"
    Write-Host "----------------------------------"
    Write-Host "--------------"
    Write-Host
    Write-Host "........PROCESSING DONE............" -ForegroundColor Yellow

    # Checks the size of the mailbox of the $email user

    $itemsize = Get-MailboxStatistics -Identity $email | Select-Object DisplayName, MailboxTypeDetail, IsValid, ItemCount, @{Name = "totalItemSize"; e = { $_.TotalItemSize } }

    # This block checks the last time Managed Folder Assistant ran on the $email variable

    $logProps = Export-MailboxDiagnosticLogs $email -ExtendedProperties
    $xmlprops = [xml]($logProps.MailboxLog)
    $LastProcessed = ($xmlprops.Properties.MailboxTable.Property | Where-Object { $_.Name -like "*ELCLastSuccessTimestamp*" }).Value
    $ItemsDeleted = $xmlprops.Properties.MailboxTable.Property | Where-Object { $_.Name -like "*ElcLastRunDeletedFromRootItemCount*" }

    #creating a custom object to display all results

    $ReportLine = [PSCustomObject]@{
        DisplayName        = $itemsize.DisplayName
        EmailAdress        = $email
        MailboxTypeDetail  = $itemsize.MailboxTypeDetail
        IsValid            = $itemsize.IsValid
        ItemCount          = $itemsize.ItemCount
        CurrentMailboxSize = $($itemsize.TotalItemSize)
        MFA_LastProcessed  = $LastProcessed
        ItemsDeleted       = $ItemsDeleted.Value
    }

    Write-Host "................................................."
    Write-Host "......................................."
    Write-Host
    Write-Host "Here are the results: " -ForegroundColor Yellow -NoNewline
    $ReportLine | Format-List

}