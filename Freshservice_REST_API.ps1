
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

$t16 = $stock | Where-Object { $_.Name -like "*T16*" } | Select-Object
$t14 = $stock | Where-Object { $_.Name -like "*T14*" }
$x1nano = $stock | Where-Object { $_.Name -like "*Nano*" }
$x1carbon = $stock | Where-Object { $_.Name -like "*Carbon*" }
$dock = $stock | Where-Object { $_.Name -like "*Dock*" }
$phones = $stock | Where-Object { $_.Name -like "Apple*" }
$mk320 = $allassets | Where-Object { $_.Name -like "*M&K*" }
$h540 = $allassets | Where-Object { $_.Name -like "*Headset*" }

$results = @(
    [PSCustomObject]@{ 'Name' = 'T16 Laptops'; 'Quantity' = $t16.Count }
    [PSCustomObject]@{ 'Name' = 'T14 Laptops'; 'Quantity' = $t14.Count }
    [PSCustomObject]@{ 'Name' = 'x1 Nano Laptops'; 'Quantity' = $x1nano.Count }
    [PSCustomObject]@{ 'Name' = 'x1 Carbon Laptops'; 'Quantity' = $x1carbon.Count }
    [PSCustomObject]@{ 'Name' = 'Docking Stations'; 'Quantity' = $dock.Count }
    [PSCustomObject]@{ 'Name' = 'Mobile Phones'; 'Quantity' = $phones.Count }
)


$JSON = [Ordered]@{
    "type"        = "message"
    "summary"     = "INVENTORY STOCK ALERT!!~"
    "attachments" = @(
        @{
            "contentType" = 'application/vnd.microsoft.card.adaptive'
            "content"     = [Ordered]@{
                '$schema' = "http://adaptivecards.io/schemas/adaptive-card.json"
                "type"    = "AdaptiveCard"
                "version" = "1.0"
                "body"    = @(
                    @{
                        "type"   = "TextBlock"
                        "color"  = "good"
                        "text"   = "Inventory Update as of: $(Get-Date)"
                        "style"  = "heading"
                        "weight" = "bolder"
                    }
                    @{
                        "type"              = "Table"
                        "gridStyle"         = "accent"
                        "firstRowAsHeaders" = $true
                        "columns"           = @(
                            @{
                                "width" = "stretch"
                                "items" = @(
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = ""
                                        "wrap"                = $true
                                        "weight"              = "bolder"
                                        "horizontalAlignment" = "left"
                                    }
                                )
                            }
                            @{
                                "width" = "stretch"
                                "items" = @(
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "QUANTITY"
                                        "weight"              = "Bolder"
                                        "horizontalAlignment" = "right"
                                    }
                                )
                            }
                        )
                        "rows"              = @(
                            @{
                                "type"  = "TableRow"
                                "cells" = @(
                                    @{
                                        "type"  = "TableCell"
                                        "items" = @(
                                            @{
                                                "type"   = "TextBlock"
                                                "text"   = ""
                                                "wrap"   = $true
                                                "weight" = "bolder"
                                            }
                                        )
                                    }
                                    @{
                                        "type"  = "TableCell"
                                        "items" = @(
                                            @{
                                                "type"                = "TextBlock"
                                                "text"                = "QUANTITY"
                                                "isSubtle"            = $false
                                                "spacing"             = "none"
                                                "weight"              = "bolder"
                                                "horizontalAlignment" = "center"
                                            }
                                        )
                                    }
                                )
                            }
                            @{
                                "type"  = "TableRow"
                                "cells" = @(
                                    @{
                                        "type"  = "TableCell"
                                        "items" = @(
                                            @{
                                                "type"   = "TextBlock"
                                                "text"   = "T16 Laptops"
                                                "wrap"   = $true
                                                "weight" = "none"
                                            }
                                        )
                                    }
                                    @{
                                        "type"  = "TableCell"
                                        "items" = @(
                                            @{
                                                "type"                = "TextBlock"
                                                "text"                = "$($t16.Count)"
                                                "isSubtle"            = $true
                                                "spacing"             = "none"
                                                "horizontalAlignment" = "center"
                                            }
                                        )
                                    }
                                )
                            }
                            @{
                                "type"  = "TableRow"
                                "cells" = @(
                                    @{
                                        "type"  = "TableCell"
                                        "items" = @(
                                            @{
                                                "type"   = "TextBlock"
                                                "text"   = "T14 Laptops"
                                                "wrap"   = $true
                                                "weight" = "bold"
                                            }
                                        )
                                    }
                                    @{
                                        "type"  = "TableCell"
                                        "items" = @(
                                            @{
                                                "type"                = "TextBlock"
                                                "text"                = "$($t14.Count)"
                                                "isSubtle"            = $true
                                                "spacing"             = "none"
                                                "horizontalAlignment" = "center"
                                            }
                                        )
                                    }
                                )
                            }
                            @{
                                "type"  = "TableRow"
                                "cells" = @(
                                    @{
                                        "type"  = "TableCell"
                                        "items" = @(
                                            @{
                                                "type"   = "TextBlock"
                                                "text"   = "x1 Carbon Laptops"
                                                "wrap"   = $true
                                                "weight" = "bold"
                                            }
                                        )
                                    }
                                    @{
                                        "type"  = "TableCell"
                                        "items" = @(
                                            @{
                                                "type"                = "TextBlock"
                                                "text"                = "$($x1carbon.Count)"
                                                "isSubtle"            = $true
                                                "spacing"             = "none"
                                                "horizontalAlignment" = "center"
                                            }
                                        )
                                    }
                                )
                            }
                            @{
                                "type"  = "TableRow"
                                "cells" = @(
                                    @{
                                        "type"  = "TableCell"
                                        "items" = @(
                                            @{
                                                "type"   = "TextBlock"
                                                "text"   = "x1 Nano Laptops"
                                                "wrap"   = $true
                                                "weight" = "bold"
                                            }
                                        )
                                    }
                                    @{
                                        "type"  = "TableCell"
                                        "items" = @(
                                            @{
                                                "type"                = "TextBlock"
                                                "text"                = "$($x1nano.Count)"
                                                "isSubtle"            = $true
                                                "spacing"             = "none"
                                                "horizontalAlignment" = "center"
                                            }
                                        )
                                    }
                                )
                            }
                            @{
                                "type"  = "TableRow"
                                "cells" = @(
                                    @{
                                        "type"  = "TableCell"
                                        "items" = @(
                                            @{
                                                "type"   = "TextBlock"
                                                "text"   = "ThinkPad T4 Docking Stations"
                                                "wrap"   = $true
                                                "weight" = "bold"
                                            }
                                        )
                                    }
                                    @{
                                        "type"  = "TableCell"
                                        "items" = @(
                                            @{
                                                "type"                = "TextBlock"
                                                "text"                = "$($dock.Count)"
                                                "isSubtle"            = $true
                                                "spacing"             = "none"
                                                "horizontalAlignment" = "center"
                                            }
                                        )
                                    }
                                )
                            }
                            @{
                                "type"  = "TableRow"
                                "cells" = @(
                                    @{
                                        "type"  = "TableCell"
                                        "items" = @(
                                            @{
                                                "type"   = "TextBlock"
                                                "text"   = "Mobile Phones"
                                                "wrap"   = $true
                                                "weight" = "bold"
                                            }
                                        )
                                    }
                                    @{
                                        "type"  = "TableCell"
                                        "items" = @(
                                            @{
                                                "type"                = "TextBlock"
                                                "text"                = "$($phones.Count)"
                                                "isSubtle"            = $true
                                                "spacing"             = "none"
                                                "horizontalAlignment" = "center"
                                            }
                                        )
                                    }
                                )
                            }
                            @{
                                "type"  = "TableRow"
                                "cells" = @(
                                    @{
                                        "type"  = "TableCell"
                                        "items" = @(
                                            @{
                                                "type"   = "TextBlock"
                                                "text"   = "MK320 - Mouse and Keyboard"
                                                "wrap"   = $true
                                                "weight" = "bold"
                                            }
                                        )
                                    }
                                    @{
                                        "type"  = "TableCell"
                                        "items" = @(
                                            @{
                                                "type"                = "TextBlock"
                                                "text"                = "$($mk320.type_fields.quantity_16000332716)"
                                                "isSubtle"            = $true
                                                "spacing"             = "none"
                                                "horizontalAlignment" = "center"
                                            }
                                        )
                                    }
                                )
                            }
                            @{
                                "type"  = "TableRow"
                                "cells" = @(
                                    @{
                                        "type"  = "TableCell"
                                        "items" = @(
                                            @{
                                                "type"   = "TextBlock"
                                                "text"   = "H540 - Headset"
                                                "wrap"   = $true
                                                "weight" = "bold"
                                            }
                                        )
                                    }
                                    @{
                                        "type"  = "TableCell"
                                        "items" = @(
                                            @{
                                                "type"                = "TextBlock"
                                                "text"                = "$($h540.type_fields.quantity_16000332716)"
                                                "isSubtle"            = $true
                                                "spacing"             = "none"
                                                "horizontalAlignment" = "center"
                                            }
                                        )
                                    }
                                )
                            }
                            # ... Repeat similar rows for other items like X1 Nano Laptops, X1 Carbon Laptops, Docking Stations, and Mobile Phones ...
                        )
                    }
                )
            }
        }
    )
} | ConvertTo-Json -Depth 20

$parameters = @{
    "URI"         = "https://greatbuildersolutions.webhook.office.com/webhookb2/cec7e207-dcbe-46af-ab09-0fada3fa2281@6b152703-09ac-40ef-87cb-89f5be3bb6aa/IncomingWebhook/e566a076e59e4479b7f844df1cdfad92/a258c296-5ad3-49a6-91cf-b271bd53fb2d"
    "Method"      = "POST"
    "Body"        = $JSON
    "ContentType" = "application/json"
}

Invoke-RestMethod @parameters

