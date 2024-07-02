Function Get-MailboxSize {

    <#
        .DESCRIPTION
        This function retrieves the total mailbox size of a specified user/mailbox.
        `

        .EXAMPLE
        Get-MailboxSize -UserPrincipalName Brylle.Purificacion@greatgulf.com
        `
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [string]$UserPrincipalName #firstname.lastname
    )

    $requiredModules = @("ExchangeOnlineManagement")
    $ErrorActionPreference = 'SilentlyContinue'

    foreach ($module in $requiredModules) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            Write-Host "Installing module: $module"
            Install-Module -Name $module -Force -AllowClobber
        }
    }

    Try {
        # Connect to Exchange Online
        if (-not (Get-PSSession | Select-Object -Property Name -First 1 | Where-Object { $_.Name -eq "ExchangeOnline*" })) {
            Write-Host "Connecting to Exchange Online..."
            Connect-ExchangeOnline
            Write-Host "Successfully connected to Exchange Online." -ForegroundColor Yellow
        } else {
            Write-Host "Successfully connected to Exchange Online." -ForegroundColor Yellow
        }

        $userdetails = get-Mailbox -Identity $UserPrincipalName | Select-Object Name, PrimarySmtpAddress

        $mailboxsize = Get-MailboxStatistics -Identity $UserPrincipalName | Select-Object ItemCount, TotalItemSize

        $results = [ordered]@{
            'MailboxOwner'        = $userdetails.Name
            'MailboxEmailAddress' = $userdetails.PrimarySmtpAddress
            'MailboxSize'         = $mailboxsize.TotalItemSize
            'TotalEmailCount'     = $mailboxsize.ItemCount
        }
        $results
    }
} Catch {
    Write-Host "Something unexpected happened.. Please try again later..."
}