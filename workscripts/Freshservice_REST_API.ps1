﻿
#$APIKey = Import-Clixml -Path "C:\Users\brylle.purificacion\OneDrive - Great Gulf Group\Desktop\scripts\freshservice_api.xml"

$APIKey = 'yXlSTOK9dxuazwqNl4A'

$EncodedCredentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(('{0}:{1}' -f $APIKey.String, $null)))
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
$mk320 = $allassets | Where-Object { $_.Name -like "*M&K*" } | Select-Object $_.type_fields.quantity_16000332716
$h540 = $allassets | Where-Object { $_.Name -like "*Headset*" } | Select-Object $_.type_fields.quantity_16000332716

# Different dummy object array with few elements as ordered dictionary or hashtable
$ObjectsHashes = @(
    [PSCustomObject]@{ 'Name' = 'T16 Laptops'; 'Quantity' = $t16.Count }
    [PSCustomObject]@{ 'Name' = 'T14 Laptops'; 'Quantity' = $t14.Count }
    [PSCustomObject]@{ 'Name' = 'x1 Nano Laptops'; 'Quantity' = $x1nano.Count }
    [PSCustomObject]@{ 'Name' = 'x1 Carbon Laptops'; 'Quantity' = $x1carbon.Count }
    [PSCustomObject]@{ 'Name' = 'Docking Stations'; 'Quantity' = $dock.Count }
    [PSCustomObject]@{ 'Name' = 'Mobile Phones'; 'Quantity' = $phones.Count }
    [PSCustomObject]@{ 'Name' = 'MK320 - Mouse/Keyboard'; 'Quantity' = $mk320.type_fields.quantity_16000332716 }
    [PSCustomObject]@{ 'Name' = 'H540 - Headset'; 'Quantity' = $h540.type_fields.quantity_16000332716 }
)

$URI = "https://greatbuildersolutions.webhook.office.com/webhookb2/cec7e207-dcbe-46af-ab09-0fada3fa2281@6b152703-09ac-40ef-87cb-89f5be3bb6aa/IncomingWebhook/fd524be7c9e44c22b080dc599908d4c0/a258c296-5ad3-49a6-91cf-b271bd53fb2d"

$Card = New-AdaptiveCard {
    New-AdaptiveTextBlock -Size 'Medium' -Color Good -FontType Monospace -Weight Bolder -Text "Updated as of: $(Get-Date)" -Wrap
    New-AdaptiveTable -DataTable $ObjectsHashes -HorizontalAlignment Center -Size Medium  -HeaderHorizontalAlignment Center -HeaderWeight Bolder
    New-AdaptiveColumnSet {
        New-AdaptiveColumn {
            New-AdaptiveTextBlock "" -HorizontalAlignment Center
        }
        New-AdaptiveColumn {
            New-AdaptiveActionSet {
                New-AdaptiveAction -Title "FreshService Inventory Link" -ActionUrl "https://greatgulfhelpdesk.freshservice.com/cmdb/items"
            }
        } -Width Auto
        New-AdaptiveColumn {
            New-AdaptiveTextBlock "" -HorizontalAlignment Center
        }
    }
} -Uri $URI -FullWidth -ReturnJson


