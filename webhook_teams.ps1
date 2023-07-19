
$date = Get-Date

$JSON = [Ordered]@{
    "type"        = "message"
    "attachments" = @(
        @{
            "contentType" = 'application/vnd.microsoft.card.adaptive'
            "content"     = [Ordered]@{
                '$schema' = "<http://adaptivecards.io/schemas/adaptive-card.json>"
                "type"    = "AdaptiveCard"
                "version" = "1.0"
                "body"    = @(
                    @{
                        "type"   = "TextBlock"
                        "color"  = "good"
                        "text"   = "Inventory Update: $date"
                        "weight" = "bolder"
                    }
                    @{
                        "type"    = "ColumnSet"
                        "spacing" = "medium"
                        "columns" = @(
                            @{
                                "type"  = "Column"
                                "width" = 4
                                "items" = @(
                                    @{
                                        "type" = "TextBlock"
                                        "text" = "MK320 - (Mouse and Keyboard)"
                                    }
                                    @{
                                        "type"     = "TextBlock"
                                        "text"     = "Quantity: 5"
                                        "isSubtle" = $true
                                        "spacing"  = "none"
                                    }
                                )
                            }
                        )
                    }
                    @{
                        "type"    = "ColumnSet"
                        "spacing" = "medium"
                        "columns" = @(
                            @{
                                "type"  = "Column"
                                "width" = 4
                                "items" = @(
                                    @{
                                        "type" = "TextBlock"
                                        "text" = "H540 - (Headset)"
                                    }
                                    @{
                                        "type"     = "TextBlock"
                                        "text"     = "Quantity: 7"
                                        "isSubtle" = $true
                                        "spacing"  = "none"
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
                                "width" = 4
                                "items" = @(
                                    @{
                                        "type" = "TextBlock"
                                        "text" = "T16 i5 Laptops"
                                    }
                                    @{
                                        "type"     = "TextBlock"
                                        "text"     = "Quantity: 15"
                                        "isSubtle" = $true
                                        "spacing"  = "none"
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
                                "width" = "auto"
                                "items" = @(
                                    @{
                                        "type"    = "Image"
                                        "url"     = "https://unsplash.it/80?image=1080"
                                        "altText" = "The Witcher"
                                        "size"    = "medium"
                                    }
                                )
                            }
                            @{
                                "type"  = "Column"
                                "width" = 4
                                "items" = @(
                                    @{
                                        "type" = "TextBlock"
                                        "text" = "T14 i5 Laptops"
                                    }
                                    @{
                                        "type"     = "TextBlock"
                                        "text"     = "Quantity: 5"
                                        "isSubtle" = $true
                                        "spacing"  = "none"
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
    "URI"         = "https://greatbuildersolutions.webhook.office.com/webhookb2/cec7e207-dcbe-46af-ab09-0fada3fa2281@6b152703-09ac-40ef-87cb-89f5be3bb6aa/IncomingWebhook/08dc23e62acb468bb79a8791c139a3c1/a258c296-5ad3-49a6-91cf-b271bd53fb2d"
    "Method"      = "POST"
    "Body"        = $JSON
    "ContentType" = "application/json"
}

Invoke-RestMethod @parameters
