﻿﻿
$APIKey = 'yXlSTOK9dxuazwqNl4A'
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

$t16 = $stock | Where-Object { $_.Name -like "*T16*" }
$t14 = $stock | Where-Object { $_.Name -like "*T14*" }
$x1nano = $stock | Where-Object { $_.Name -like "*Nano*" }
$x1carbon = $stock | Where-Object { $_.Name -like "*Carbon*" }
$dock = $stock | Where-Object { $_.Name -like "*Dock*" }
$phones = $stock | Where-Object { $_.Name -like "Apple*" }
$mk320 = $allassets | Where-Object { $_.Name -like "*M&K*" } | Select-Object Name, @{n = 'Count'; e = { $_.type_fields.quantity_16000332716 } }
$h540 = $allassets | Where-Object { $_.Name -like "*Headset*" } | Select-Object Name, @{n = 'Count'; e = { $_.type_fields.quantity_16000332716 } }

$vartoCheck = @($t16, $t14, $x1nano, $x1carbon, $dock, $phones, $mk320, $h540)

$lowQuantityItems = @()
try {
    foreach ($item in $vartoCheck) {
        if ($item.Count -le 5) {
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
    $JSON = @{
        "type"        = "message"
        "summary"     = "Low Quantity Asset Alert!!~"
        "attachments" = @(
            @{
                "contentType" = "application/vnd.microsoft.card.adaptive"
                "content"     = @{
                    "$schema" = "http://adaptivecards.io/schemas/adaptive-card.json"
                    "type"    = "AdaptiveCard"
                    "version" = "1.2"
                    "body"    = @(
                        @{
                            "type"          = "TextBlock"
                            "text"          = "Updated as of: $(Get-Date)"
                            "size"          = "Medium"
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
                            "size"   = "medium"
                            "color"  = "Warning"
                        },
                        @{
                            "type"    = "ColumnSet"
                            "columns" = $lowQuantityItems | ForEach-Object {
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
                                        }
                                        @{
                                            "type"                = "TextBlock"
                                            "text"                = $_.AssetName
                                            "horizontalAlignment" = "Center"
                                            "weight"              = "Bolder"
                                            "color"               = "Light"
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
                                            "color"               = "Accent"
                                        }
                                        @{
                                            "type"                = "TextBlock"
                                            "text"                = $_.Quantity
                                            "horizontalAlignment" = "Center"
                                            "weight"              = "Bolder"
                                            "color"               = "Light"
                                        }
                                    )
                                }
                            }
                        }
                    )
                }
            }
        )
    } | ConvertTo-Json -Depth 20
} catch {
    Write-Host "Something unexpected happened. Please try again later."
}

$parameters = @{
    "URI"         = "https://greatbuildersolutions.webhook.office.com/webhookb2/cec7e207-dcbe-46af-ab09-0fada3fa2281@6b152703-09ac-40ef-87cb-89f5be3bb6aa/IncomingWebhook/fd524be7c9e44c22b080dc599908d4c0/a258c296-5ad3-49a6-91cf-b271bd53fb2d"
    "Method"      = "POST"
    "Body"        = $JSON
    "ContentType" = "application/json"
}

Invoke-RestMethod @parameters



