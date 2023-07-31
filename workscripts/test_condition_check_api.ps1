try {
    $lowQuantityItems = @()

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

    if ($lowQuantityItems.Count -eq 0) {
        Write-Host "No assets found with low quantity. Exiting..."
        return
    }

    $JSON = @{
        "type"        = "message"
        "summary"     = "LOW QUALITY ASSET !!! ~"
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
                            "text"          = "Updated as of: $(Get-Date -Format "dddd, yyyy/MM/dd")"
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
        "URI"         = "https://greatbuildersolutions.webhook.office.com/webhookb2/cec7e207-dcbe-46af-ab09-0fada3fa2281@6b152703-09ac-40ef-87cb-89f5be3bb6aa/IncomingWebhook/fd524be7c9e44c22b080dc599908d4c0/a258c296-5ad3-49a6-91cf-b271bd53fb2d"
        "Method"      = "POST"
        "Body"        = $JSON
        "ContentType" = "application/json"
    }

    Invoke-RestMethod @parameters
} catch {
    Write-Host "Something unexpected happened. Please try again later."
}
