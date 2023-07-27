
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


$array = @(
    [PSCustomObject]@{ 'Asset' = 'T16 Laptops'; 'Quantity' = $t16.Count }
    [PSCustomObject]@{ 'Asset' = 'T14 Laptops'; 'Quantity' = $t14.Count }
    [PSCustomObject]@{ 'Asset' = 'x1 Nano Laptops'; 'Quantity' = $x1nano.Count }
    [PSCustomObject]@{ 'Asset' = 'x1 Carbon Laptops'; 'Quantity' = $x1carbon.Count }
    [PSCustomObject]@{ 'Asset' = 'Docking Stations'; 'Quantity' = $dock.Count }
    [PSCustomObject]@{ 'Asset' = 'Mobile Phones'; 'Quantity' = $phones.Count }
    [PSCustomObject]@{ 'Asset' = 'MK320 - Mouse/Keyboard'; 'Quantity' = $mk320.Count }
    [PSCustomObject]@{ 'Asset' = 'H540 - Headset'; 'Quantity' = $h540.Count }
)

foreach ($item in $array) {
    if ($item.Quantity -le 5) {
    }
}

$Card = New-AdaptiveCard {
    New-AdaptiveTextBlock -Size 'Small' -Color Good -FontType Monospace -Weight Bolder -Text "Updated as of $(Get-Date)" -Wrap
    New-AdaptiveTable -Spacing Medium -Weight Bolder -HeaderWeight Bolder -Size Small -DataTable $array -HeaderHorizontalAlignment Center -HeaderColor Attention -HorizontalAlignment Center
    New-AdaptiveColumnSet {
        New-AdaptiveColumn {
            New-AdaptiveTextBlock -Size 'Small' -Color Good -FontType Monospace -Weight Bolder -Hidden -Text ">>>>>" -HorizontalAlignment Center
        }
        New-AdaptiveColumn {
            New-AdaptiveActionSet {
                New-AdaptiveAction -Title 'INVENTORY LINK' -ActionUrl 'https://www.google.com'
            }
        } -Width Auto
        New-AdaptiveColumn {
            New-AdaptiveTextBlock -Size 'Small' -Color Good -FontType Monospace -Weight Bolder -Hidden -Text "<<<<<" -HorizontalAlignment Center
        }
    }
} -Uri $testuri -FullWidth -ReturnJson

