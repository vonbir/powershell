﻿
# -File C:\Users\brylle.purificacion\powershell\workscripts\inventory_stock_alert.ps1 -ExecutionPolicy Bypass -NoProfile -NonInteractive

$APIKey = Import-Clixml -Path "C:\Users\brylle.purificacion\apikey.txt"

$EncodedCredentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(('{0}:{1}' -f $APIKey, $null)))
$HTTPHeaders = @{}
$HTTPHeaders.Add('Authorization', ('Basic {0}' -f $EncodedCredentials))

# Create an ArrayList for better processing
$allAssets = New-Object System.Collections.ArrayList

try {
    $maxPage = 60  # Set the maximum number of pages to iterate through

    # Use a for loop to iterate through the pages
    for ($i = 1; $i -le $maxPage; $i++) {
        $URL = "https://greatgulfhelpdesk.freshservice.com/api/v2/assets?include=type_fields&per_page=100&page=$i"

        # Send the API request using Invoke-RestMethod
        $response = Invoke-RestMethod -Uri $URL -Headers $HTTPHeaders -Method Get -ContentType application/json

        if ($response.assets) {
            # Add assets from the current page to the ArrayList
            $allAssets.AddRange($response.assets)
        } else {
            # Break the loop if there are no more items
            break
        }
    }
} catch {
    Write-Host "An error occurred while fetching assets: $_" -ForegroundColor Red
}

## pulls all assets in stock

$stock = $allAssets | Where-Object { $_.type_fields.asset_state_16000332715 -eq "In Stock" }

#declares diff. variables per item

$t16 = $stock | Where-Object { $_.name -like "*T16 Gen 1*" }
$t14 = $stock | Where-Object { $_.name -like "*T14 Gen 3*" }
$x1nano = $stock | Where-Object { $_.name -like "*X1 Nano Gen 1*" }
$x1carbon = $stock | Where-Object { $_.name -like "*x1 Carbon Gen 10*" }
$desktops = $stock | Where-Object { $_.name -like "*M90q*" }
$monitors = $stock | Where-Object { $_.name -like "*T27h*" }
$dock = $stock | Where-Object { $_.name -like "*Thinkpad Thunderbolt 4 Dock*" }
$phones = $stock | Where-Object { $_.name -like "Apple*" }
$mk320 = $allassets | Where-Object { $_.name -like "*M&K*" } | Select-Object @{n = 'Count'; e = { $_.type_fields.quantity_16000332716 } }
$h540 = $allassets | Where-Object { $_.name -like "*Headset*" } | Select-Object @{n = 'Count'; e = { $_.type_fields.quantity_16000332716 } }

$vartoCheck = @($t16, $t14, $x1nano, $x1carbon, $desktops, $dock, $phones, $mk320, $h540, $monitors)

$lowQuantityItems = @()
try {
    $lowQuantityItems = @()

    foreach ($item in $vartoCheck) {
        if ($item.Count -le 6) {
            $itemName = if ($item -is [System.Management.Automation.PSCustomObject]) {
                $item.Name
            } else {
                $item[0].Name
            }
            $lowQuantityItems += @{
                "AssetName" = $itemName
                "Quantity"  = $item.Count
            }
        }
    }

    if ($lowQuantityItems.Count -eq 0) {
        return
    }

    $JSON = @{
        "type"        = "message"
        "summary"     = "Low Quantity Alert !!! ~"
        "attachments" = @(
            @{
                "contentType" = "application/vnd.microsoft.card.adaptive"
                "content"     = @{
                    "$schema" = "http://adaptivecards.io/schemas/adaptive-card.json"
                    "type"    = "AdaptiveCard"
                    "version" = "1.2"
                    "msteams" = @{"width" = "Full" }
                    "body"    = @(
                        @{
                            "type"          = "TextBlock"
                            "text"          = "Updated as of: $(Get-Date -Format "dddd, yyyy/MM/dd, hh:MM:ss")"
                            "size"          = "Small"
                            "weight"        = "Bolder"
                            "color"         = "Good"
                            "fontType"      = "Monospace"
                            "highlight"     = $false
                            "italic"        = $false
                            "strikeThrough" = $false
                            "wrap"          = $true
                        }
                        @{
                            "type"   = "TextBlock"
                            "text"   = "The following assets are LOW in stock:"
                            "weight" = "Bolder"
                            "wrap"   = $true
                            "style"  = "heading"
                            "size"   = "Large"
                            "color"  = "Warning"
                        },
                        @{
                            "type"    = "ColumnSet"
                            "columns" = @(
                                @{
                                    "type"  = "Column"
                                    "width" = "stretch"
                                    "items" = @(
                                        @{
                                            "type"                = "TextBlock"
                                            "text"                = "Asset"
                                            "horizontalAlignment" = "Center"
                                            "weight"              = "Bolder"
                                            "color"               = "Accent"
                                            "size"                = "Medium"
                                        }
                                        $lowQuantityItems | ForEach-Object {
                                            @{
                                                "type"                = "TextBlock"
                                                "text"                = $_.AssetName
                                                "horizontalAlignment" = "Center"
                                                "weight"              = "Bolder"
                                                "color"               = "Light"
                                            }
                                        }
                                    )
                                }
                                @{
                                    "type"  = "Column"
                                    "width" = "stretch"
                                    "items" = @(
                                        @{
                                            "type"                = "TextBlock"
                                            "text"                = "Quantity"
                                            "horizontalAlignment" = "Center"
                                            "weight"              = "Bolder"
                                            "size"                = "Medium"
                                            "color"               = "Accent"
                                        }
                                        $lowQuantityItems | ForEach-Object {
                                            @{
                                                "type"                = "TextBlock"
                                                "text"                = $_.Quantity
                                                "horizontalAlignment" = "Center"
                                                "weight"              = "Bolder"
                                                "color"               = "Light"
                                                "subtle"              = "true"
                                            }
                                        }
                                    )
                                }
                            )
                        }
                    )
                }
            }
        )
    } | ConvertTo-Json -Depth 20

    $parameters = @{
        "URI"         = "https://greatbuildersolutions.webhook.office.com/webhookb2/1386cb5b-c516-43d4-b5db-a49fc389e971@6b152703-09ac-40ef-87cb-89f5be3bb6aa/IncomingWebhook/832225d99dac4323959b3f40e64b4900/a258c296-5ad3-49a6-91cf-b271bd53fb2d"
        # test "URI"         = "https://greatbuildersolutions.webhook.office.com/webhookb2/cec7e207-dcbe-46af-ab09-0fada3fa2281@6b152703-09ac-40ef-87cb-89f5be3bb6aa/IncomingWebhook/fb68fb1cda06423ba0b1947f9a3405d0/a258c296-5ad3-49a6-91cf-b271bd53fb2d"
        "Method"      = "POST"
        "Body"        = $JSON
        "ContentType" = "application/json"
    }

    Invoke-RestMethod @parameters
} catch {
    Write-Host "Something unexpected happened. Please try again later."
}