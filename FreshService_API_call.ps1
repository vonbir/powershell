
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

$t16 = $stock | Where-Object { $_.Name -like "*T16*" } | Select-Object
$t14 = $stock | Where-Object { $_.Name -like "*T14*" }
$x1nano = $stock | Where-Object { $_.Name -like "*Nano*" }
$x1carbon = $stock | Where-Object { $_.Name -like "*Carbon*" }
$dock = $stock | Where-Object { $_.Name -like "*Dock*" }
$phones = $stock | Where-Object { $_.Name -like "Apple*" }
$mk320 = $allassets | Where-Object { $_.Name -like "*M&K*" }
$h540 = $allassets | Where-Object { $_.Name -like "*Headset*" }

# $results = @(
#     [PSCustomObject]@{ 'Name' = 'T16 Laptops'; 'Quantity' = $t16.Count }
#     [PSCustomObject]@{ 'Name' = 'T14 Laptops'; 'Quantity' = $t14.Count }
#     [PSCustomObject]@{ 'Name' = 'x1 Nano Laptops'; 'Quantity' = $x1nano.Count }
#     [PSCustomObject]@{ 'Name' = 'x1 Carbon Laptops'; 'Quantity' = $x1carbon.Count }
#     [PSCustomObject]@{ 'Name' = 'Docking Stations'; 'Quantity' = $dock.Count }
#     [PSCustomObject]@{ 'Name' = 'Mobile Phones'; 'Quantity' = $phones.Count }
# )


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
                        "type"     = "TextBlock"
                        "color"    = "good"
                        "text"     = "Update as of: $(Get-Date)"
                        "size"     = "small"
                        "style"    = "heading"
                        "fonttype" = "monospace"
                    }
                    @{
                        "type"    = "ColumnSet"
                        "columns" = @(
                            @{
                                "width" = "stretch"
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
                                "width" = "stretch"
                                "items" = @(
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = ""
                                        "weight"              = "Bolder"
                                        "horizontalAlignment" = "center"
                                    }
                                )
                            }
                        )
                    }
                    @{
                        "type"    = "ColumnSet"
                        "columns" = @(
                            @{
                                "width" = "stretch"
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
                                "width" = "stretch"
                                "items" = @(
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "Quantity"
                                        "weight"              = "Bolder"
                                        "horizontalAlignment" = "center"
                                    }
                                )
                            }
                        )
                    }
                    @{
                        "type"    = "ColumnSet"
                        "columns" = @(
                            @{
                                "width" = "stretch"
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
                                "width" = "stretch"
                                "items" = @(
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "$($t16.Count)"
                                        "isSubtle"            = $true
                                        "spacing"             = "medium"
                                        "horizontalAlignment" = "center"
                                    }
                                )
                            }
                        )
                    }
                    @{
                        "type"    = "ColumnSet"
                        "columns" = @(
                            @{
                                "width" = "stretch"
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
                                "width" = "stretch"
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
                        "type"    = "ColumnSet"
                        "columns" = @(
                            @{
                                "width" = "stretch"
                                "items" = @(
                                    @{
                                        "type"   = "TextBlock"
                                        "text"   = "X1 Carbon Laptops"
                                        "wrap"   = $true
                                        "weight" = "bold"
                                    }
                                )
                            }
                            @{
                                "width" = "stretch"
                                "items" = @(
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "$($x1carbon.Count)"
                                        "isSubtle"            = $true
                                        "spacing"             = "medium"
                                        "horizontalAlignment" = "center"
                                    }
                                )
                            }
                        )
                    }
                    @{
                        "type"    = "ColumnSet"
                        "columns" = @(
                            @{
                                "width" = "stretch"
                                "items" = @(
                                    @{
                                        "type"   = "TextBlock"
                                        "text"   = "X1 Nano Laptops"
                                        "wrap"   = $true
                                        "weight" = "bold"
                                    }
                                )
                            }
                            @{
                                "width" = "stretch"
                                "items" = @(
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "$($x1nano.Count)"
                                        "isSubtle"            = $true
                                        "spacing"             = "medium"
                                        "horizontalAlignment" = "center"
                                    }
                                )
                            }
                        )
                    }
                    @{
                        "type"    = "ColumnSet"
                        "columns" = @(
                            @{
                                "width" = "stretch"
                                "items" = @(
                                    @{
                                        "type"   = "TextBlock"
                                        "text"   = "Thunderbolt 4 Docks"
                                        "wrap"   = $true
                                        "weight" = "bold"
                                    }
                                )
                            }
                            @{
                                "width" = "stretch"
                                "items" = @(
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "$($dock.Count)"
                                        "isSubtle"            = $true
                                        "spacing"             = "medium"
                                        "horizontalAlignment" = "center"
                                    }
                                )
                            }
                        )
                    }
                    @{
                        "type"    = "ColumnSet"
                        "columns" = @(
                            @{
                                "width" = "stretch"
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
                                "width" = "stretch"
                                "items" = @(
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "$($phones.Count)"
                                        "isSubtle"            = $true
                                        "spacing"             = "medium"
                                        "horizontalAlignment" = "center"
                                    }
                                )
                            }
                        )
                    }
                    @{
                        "type"    = "ColumnSet"
                        "columns" = @(
                            @{
                                "width" = "stretch"
                                "items" = @(
                                    @{
                                        "type"   = "TextBlock"
                                        "text"   = "MK320 - M&K Pair"
                                        "wrap"   = $true
                                        "weight" = "default"
                                    }
                                )
                            }
                            @{
                                "width" = "stretch"
                                "items" = @(
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "$($mk320.type_fields.quantity_16000332716)"
                                        "isSubtle"            = $true
                                        "spacing"             = "medium"
                                        "horizontalAlignment" = "center"
                                    }
                                )
                            }
                        )
                    }
                    @{
                        "type"    = "ColumnSet"
                        "columns" = @(
                            @{
                                "width" = "stretch"
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
                                "width" = "stretch"
                                "items" = @(
                                    @{
                                        "type"                = "TextBlock"
                                        "text"                = "$($h540.type_fields.quantity_16000332716)"
                                        "isSubtle"            = $true
                                        "spacing"             = "medium"
                                        "horizontalAlignment" = "center"
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
    "URI"         = "https://greatbuildersolutions.webhook.office.com/webhookb2/cec7e207-dcbe-46af-ab09-0fada3fa2281@6b152703-09ac-40ef-87cb-89f5be3bb6aa/IncomingWebhook/e566a076e59e4479b7f844df1cdfad92/a258c296-5ad3-49a6-91cf-b271bd53fb2d"
    "Method"      = "POST"
    "Body"        = $JSON
    "ContentType" = "application/json"
}

Invoke-RestMethod @parameters


$testuri = "https://greatbuildersolutions.webhook.office.com/webhookb2/cec7e207-dcbe-46af-ab09-0fada3fa2281@6b152703-09ac-40ef-87cb-89f5be3bb6aa/IncomingWebhook/e566a076e59e4479b7f844df1cdfad92/a258c296-5ad3-49a6-91cf-b271bd53fb2d"


## testing block

# New-CardList {
#     New-CardListItem -Type resultItem -Title 'T16 Laptops' -SubTitle "Quantity: $($t16.count)" -TapType openUrl -TapValue "https://greatgulfhelpdesk.freshservice.com/cmdb/items"
#     New-CardListItem -Type resultItem -Title 'T14 Laptops' -SubTitle "Quantity: $($t14.count)" -TapType imBack -TapValue "https://contoso.sharepoint.com/teams/new/"
#     New-CardListItem -Type resultItem -Title 'x1 Nano Laptops' -SubTitle "Quantity: $($x1nano.count)" -TapType openUrl -TapValue "http://trello.com"
#     New-CardListItem -Type resultItem -Title 'x1 Carbon Laptops' -SubTitle "Quantity: $($x1carbon.count)" -TapType openUrl -TapValue "http://trello.com" -Icon "https://fonts.google.com/icons?selected=Material%20Symbols%20Outlined%3Acomputer%3AFILL%400%3Bwght%40400%3BGRAD%400%3Bopsz%4048"
#     New-CardListItem -Type resultItem -Title 'T4 Docking Stations' -SubTitle "Quantity: $($dock.count)" -TapType openUrl -TapValue "http://trello.com"
#     New-CardListItem -Type resultItem -Title 'Mobile Phones' -SubTitle   "Quantity: $($phones.count)" -TapType openUrl -TapValue "http://trello.com"
#     New-CardListButton -Type openUrl - -Title 'Open Inventory Link' -Value 'https://greatgulfhelpdesk.freshservice.com/cmdb/items'
# } -Uri $testuri -Title "Updated as of: $(Get-Date)"


# Different dummy object array with few elements as ordered dictionary or hashtable
$ObjectsHashes = @(
    [ordered] @{
        'T16 Laptops'         = $t16.Count
        'T14 Laptops'         = $t14.Count
        'x1 Nano Laptops'     = $x1nano.Count
        'x1 Carbon Laptops'   = $x1carbon.Count
        'T4 Docking Stations' = $docks.count
        'Mobile Phones'       = $phones.Count
    }
)

$Card = New-AdaptiveCard {
    New-AdaptiveTextBlock -Size 'Medium' -Color Accent -FontType Monospace -Weight Bold -Text "Updated as of $(Get-Date)" -Wrap
    New-AdaptiveLineBreak
    New-AdaptiveTable -DataTable $ObjectsHashes
} -Uri $testuri -FullWidth -ReturnJson

$Card


