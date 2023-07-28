
$APIKey = 'yXlSTOK9dxuazwqNl4A'
$EncodedCredentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(('{0}:{1}' -f $APIKey, $null)))
$HTTPHeaders = @{}
$HTTPHeaders.Add('Authorization', ('Basic {0}' -f $EncodedCredentials))

# Create an ArrayList to store assets efficiently
$allAssets = New-Object System.Collections.ArrayList

try {
    $maxPage = 60  # Set the maximum number of pages to fetch

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

$stock = $allAssets | Where-Object { $_.type_fields.asset_state_16000332715 -eq "In Stock" } ## pulls all assets in stock

$t16 = $stock | Where-Object { $_.Name -like "*T16*" }
$t14 = $stock | Where-Object { $_.Name -like "*T14*" }
$x1nano = $stock | Where-Object { $_.Name -like "*Nano*" }
$x1carbon = $stock | Where-Object { $_.Name -like "*Carbon*" }
$dock = $stock | Where-Object { $_.Name -like "*Dock*" }
$phones = $stock | Where-Object { $_.Name -like "Apple*" }
$mk320 = $allassets | Where-Object { $_.Name -like "*M&K*" } | Select-Object $_.type_fields.quantity_16000332716
$h540 = $allassets | Where-Object { $_.Name -like "*Headset*" } | Select-Object $_.type_fields.quantity_16000332716

$JSON = [Ordered]@{
    "type"        = "message"
    "summary"     = "INVENTORY STOCK ALERT !!! ~"
    "attachments" = @(
        @{
            "contentType" = "application/vnd.microsoft.card.adaptive"
            "content"     = @{
                "$schema" = "http://adaptivecards.io/schemas/adaptive-card.json"
                "type"    = "AdaptiveCard"
                "version" = "1.2"
                "msteams" = @{"width" = "Full" }
                "body"    = @(@{
                        "type"                = "TextBlock"
                        "text"                = "Assets Currently In Stock"
                        "size"                = "Large"
                        "weight"              = "Bolder"
                        "color"               = "Blue"
                        "fontType"            = "default"
                        "horizontalAlignment" = "Center"
                        "highlight"           = $false
                        "italic"              = $false
                        "strikeThrough"       = $false
                        "wrap"                = $true
                    }
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
                        "type"    = "ColumnSet"
                        "columns" = @(
                            @{
                                "type"  = "Column"
                                "width" = "stretch"
                                "items" = @(
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "Name"
                                        "horizontalAlignment" = "Center"
                                        "weight"              = "Bolder"
                                        "color"               = "Accent"
                                        "highlight"           = $false
                                        "italic"              = $false
                                        "strikeThrough"       = $false
                                    }
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "T16 Laptops"
                                        "horizontalAlignment" = "Center"
                                        "size"                = "Medium"
                                        "highlight"           = $false
                                        "italic"              = $false
                                        "strikeThrough"       = $false
                                        "separator"           = $true
                                    }
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "T14 Laptops"
                                        "horizontalAlignment" = "Center"
                                        "size"                = "Medium"
                                        "highlight"           = $false
                                        "italic"              = $false
                                        "strikeThrough"       = $false
                                        "separator"           = $true
                                    }
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "x1 Nano Laptops"
                                        "horizontalAlignment" = "Center"
                                        "size"                = "Medium"
                                        "highlight"           = $false
                                        "italic"              = $false
                                        "strikeThrough"       = $false
                                        "separator"           = $true
                                    }
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "x1 Carbon Laptops"
                                        "horizontalAlignment" = "Center"
                                        "size"                = "Medium"
                                        "highlight"           = $false
                                        "italic"              = $false
                                        "strikeThrough"       = $false
                                        "separator"           = $true
                                    }
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "Docking Stations"
                                        "horizontalAlignment" = "Center"
                                        "size"                = "Medium"
                                        "highlight"           = $false
                                        "italic"              = $false
                                        "strikeThrough"       = $false
                                        "separator"           = $true
                                    }
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "Mobile Phones"
                                        "horizontalAlignment" = "Center"
                                        "size"                = "Medium"
                                        "highlight"           = $false
                                        "italic"              = $false
                                        "strikeThrough"       = $false
                                        "separator"           = $true
                                    }
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "MK320 - Mouse/Keyboard"
                                        "horizontalAlignment" = "Center"
                                        "size"                = "Medium"
                                        "highlight"           = $false
                                        "italic"              = $false
                                        "strikeThrough"       = $false
                                        "separator"           = $true
                                    }
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "H540 - Headset"
                                        "horizontalAlignment" = "Center"
                                        "size"                = "Medium"
                                        "highlight"           = $false
                                        "italic"              = $false
                                        "strikeThrough"       = $false
                                        "separator"           = $true
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
                                        "highlight"           = $false
                                        "italic"              = $false
                                        "strikeThrough"       = $false
                                    },
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "$($t16.Count)"
                                        "horizontalAlignment" = "Center"
                                        "size"                = "Medium"
                                        "highlight"           = $false
                                        "italic"              = $false
                                        "strikeThrough"       = $false
                                        "separator"           = $true
                                    },
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "$($t14.Count)"
                                        "horizontalAlignment" = "Center"
                                        "size"                = "Medium"
                                        "highlight"           = $false
                                        "italic"              = $false
                                        "strikeThrough"       = $false
                                        "separator"           = $true
                                    },
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "$($x1nano.Count)"
                                        "horizontalAlignment" = "Center"
                                        "size"                = "Medium"
                                        "highlight"           = $false
                                        "italic"              = $false
                                        "strikeThrough"       = $false
                                        "separator"           = $true
                                    },
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "$($x1carbon.Count)"
                                        "horizontalAlignment" = "Center"
                                        "size"                = "Medium"
                                        "highlight"           = $false
                                        "italic"              = $false
                                        "strikeThrough"       = $false
                                        "separator"           = $true
                                    },
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "$($dock.Count)"
                                        "horizontalAlignment" = "Center"
                                        "size"                = "Medium"
                                        "highlight"           = $false
                                        "italic"              = $false
                                        "strikeThrough"       = $false
                                        "separator"           = $true
                                    },
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "$($phones.Count)"
                                        "horizontalAlignment" = "Center"
                                        "size"                = "Medium"
                                        "highlight"           = $false
                                        "italic"              = $false
                                        "strikeThrough"       = $false
                                        "separator"           = $true
                                    },
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "$($mk320.type_fields.quantity_16000332716)"
                                        "horizontalAlignment" = "Center"
                                        "size"                = "Medium"
                                        "highlight"           = $false
                                        "italic"              = $false
                                        "strikeThrough"       = $false
                                        "separator"           = $true
                                    },
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "$($h540.type_fields.quantity_16000332716)"
                                        "horizontalAlignment" = "Center"
                                        "size"                = "Medium"
                                        "highlight"           = $false
                                        "italic"              = $false
                                        "strikeThrough"       = $false
                                        "separator"           = $true
                                    }
                                )
                            }
                        )
                    }
                    @{
                        "type"    = "ColumnSet"
                        "columns" = @(
                            @{
                                "type"  = "Column"
                                "width" = "stretch"
                                "items" = @(
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = ""
                                        "horizontalAlignment" = "Center"
                                        "weight"              = "Default"
                                        "color"               = "Accent"
                                    }
                                )
                            }
                            @{
                                "type"                 = "Column"
                                "width"                = "auto"
                                "horizontalallignment" = "center"
                                "items"                = @(
                                    @{
                                        "type"    = "ActionSet"
                                        "actions" = @(
                                            @{
                                                "type"  = "Action.OpenUrl"
                                                "color" = "Warning"
                                                "title" = "Freshservice Inventory Link"
                                                "url"   = "https://greatgulfhelpdesk.freshservice.com/cmdb/items"

                                            }
                                        )
                                    }
                                )
                            }
                            @{
                                "type"  = "Column"
                                "width" = "stretch"
                                "items" = @(
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = ""
                                        "horizontalAlignment" = "Center"
                                        "weight"              = "Default"
                                        "color"               = "Accent"
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
    "URI"         = "https://greatbuildersolutions.webhook.office.com/webhookb2/cec7e207-dcbe-46af-ab09-0fada3fa2281@6b152703-09ac-40ef-87cb-89f5be3bb6aa/IncomingWebhook/fd524be7c9e44c22b080dc599908d4c0/a258c296-5ad3-49a6-91cf-b271bd53fb2d"
    "Method"      = "POST"
    "Body"        = $JSON
    "ContentType" = "application/json"
}

Invoke-RestMethod @parameters
