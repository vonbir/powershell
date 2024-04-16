
# -File C:\Users\brylle.purificacion\powershell\workscripts\inventory_stock_alert.ps1 -ExecutionPolicy Bypass -NoProfile -NonInteractive

$APIKey = Import-Clixml -Path "C:\Users\brylle.purificacion\apikey.txt"

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

$t16 = $stock | Where-Object { $_.name -like "*T16 Gen 2*" }
$t14 = $stock | Where-Object { $_.name -like "*T14 Gen 3*" }
$x1nano = $stock | Where-Object { $_.name -like "*X1 Nano Gen 1*" }
$x1carbon = $stock | Where-Object { $_.name -like "*x1 Carbon Gen 10*" }
$desktops = $stock | Where-Object { $_.name -like "*M90q*" }
$monitors = $stock | Where-Object { $_.name -like "*T27*" }
$dock = $stock | Where-Object { $_.name -like "*Thinkpad Thunderbolt 4 Dock*" }
$phones = $stock | Where-Object { $_.name -like "Apple*" }
$mk320 = $allassets | Where-Object { $_.name -like "*M&K*" } | Select-Object $_.type_fields.quantity_16000332716
$h540 = $allassets |     Where-Object { $_.name -like "*Headset*" } | Select-Object $_.type_fields.quantity_16000332716

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
                "body"    = @(
                    @{
                        "type"                = "TextBlock"
                        "text"                = "Assets Currently In Stock"
                        "size"                = "extraLarge"
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
                        "text"          = "Updated as of: $(Get-Date -Format "dddd, yyyy/MM/dd, hh:mm:ss")"
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
                                        "text"                = "ThinkPad T16 Gen 1"
                                        "horizontalAlignment" = "Center"
                                        "size"                = "Medium"
                                        "highlight"           = $false
                                        "italic"              = $false
                                        "strikeThrough"       = $false
                                        "separator"           = $true
                                    }
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "ThinkPad T14 Gen 3"
                                        "horizontalAlignment" = "Center"
                                        "size"                = "Medium"
                                        "highlight"           = $false
                                        "italic"              = $false
                                        "strikeThrough"       = $false
                                        "separator"           = $true
                                    }
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "x1 Nano Gen 1"
                                        "horizontalAlignment" = "Center"
                                        "size"                = "Medium"
                                        "highlight"           = $false
                                        "italic"              = $false
                                        "strikeThrough"       = $false
                                        "separator"           = $true
                                    }
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "x1 Carbon Gen 10"
                                        "horizontalAlignment" = "Center"
                                        "size"                = "Medium"
                                        "highlight"           = $false
                                        "italic"              = $false
                                        "strikeThrough"       = $false
                                        "separator"           = $true
                                    }
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "ThinkCentre M90q Gen3"
                                        "horizontalAlignment" = "Center"
                                        "size"                = "Medium"
                                        "highlight"           = $false
                                        "italic"              = $false
                                        "strikeThrough"       = $false
                                        "separator"           = $true
                                    }
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "ThinkVision 27-inch Monitors"
                                        "horizontalAlignment" = "Center"
                                        "size"                = "Medium"
                                        "highlight"           = $false
                                        "italic"              = $false
                                        "strikeThrough"       = $false
                                        "separator"           = $true
                                    }
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "ThinkPad Thunderbolt 4 Docks"
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
                                        "text"                = "$($desktops.Count)"
                                        "horizontalAlignment" = "Center"
                                        "size"                = "Medium"
                                        "highlight"           = $false
                                        "italic"              = $false
                                        "strikeThrough"       = $false
                                        "separator"           = $true
                                    },
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "$($monitors.Count)"
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
                                                "title" = "FreshService Inventory Link"
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
    "URI"         = "https://greatbuildersolutions.webhook.office.com/webhookb2/1386cb5b-c516-43d4-b5db-a49fc389e971@6b152703-09ac-40ef-87cb-89f5be3bb6aa/IncomingWebhook/832225d99dac4323959b3f40e64b4900/a258c296-5ad3-49a6-91cf-b271bd53fb2d"
    "Method"      = "POST"
    "Body"        = $JSON
    "ContentType" = "application/json"
}

Invoke-RestMethod @parameters
