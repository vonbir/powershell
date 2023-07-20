

$APIKey = 'yXlSTOK9dxuazwqNl4A'
$EncodedCredentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(('{0}:{1}' -f $APIKey, $null)))

$HTTPHeaders = @{}
$HTTPHeaders.Add('Authorization', ('Basic {0}' -f $EncodedCredentials))
$URL = 'https://greatgulfhelpdesk.freshservice.com/api/v2/assets?filter="name:Lenovo"&include=type_fields'


$Params = @{
    Method      = 'Get'
    Uri         = $URL
    Headers     = $HTTPHeaders
    ContentType = 'application/json'
}

$Status = Invoke-RestMethod @Params

# lists all the 'In Stock' Lenovo laptops

$URL = 'https://greatgulfhelpdesk.freshservice.com/api/v2/assets?per_page=100;include=type_fields'

$laptops = $status.assets | Where-Object { $_.type_fields.product_16000332715 -like "16000121170" -and $_.type_fields.asset_state_16000332715 -like "In Stock" }

# lists the mk320 item details

$URL = 'https://greatgulfhelpdesk.freshservice.com/api/v2/assets/5554?include=type_fields'

$Params = @{
    Method      = 'Get'
    Uri         = $URL
    Headers     = $HTTPHeaders
    ContentType = 'application/json'
}

$Status = Invoke-RestMethod @Params

$mk320 = $status.asset | Select-Object name, @{n = "Quantity"; e = { $_.type_fields.quantity_16000332716 } }, @{n = "Asset_State"; e = { $_.type_fields.state_16000332716 } }, updated_at


# lists the mk320 item details

$URL = 'https://greatgulfhelpdesk.freshservice.com/api/v2/assets?per_page=100;include=type_fields&order_by=created_at'

$Params = @{
    Method      = 'Get'
    Uri         = $URL
    Headers     = $HTTPHeaders
    ContentType = 'application/json'
}

$Status = Invoke-RestMethod @Params
$Status

$t16laptops = $status.assets | Where-Object { $_.Name -eq "Lenovo" -and $_.type_fields.asset_state_16000332715 -eq "In Stock" }


$results = [pscustomobject][ordered]@{

    'T16 Gen1 Laptops' = "Quantity: $t16laptops.count",
    'MK320 (Mouse and Keyboard)' = "Quantity: $mk320.Quantity"

}


# $URL = 'https://greatgulfhelpdesk.freshservice.com/api/v2/assets?include=type_fields'
# $URL = 'https://greatgulfhelpdesk.freshservice.com/api/v2/assets?order_by=created_at' # sort by created by
# $URL = 'https://greatgulfhelpdesk.freshservice.com/api/v2/assets?per_page=100; include=type_fields' # include all fields and 100 per page
# $URL = 'https://greatgulfhelpdesk.freshservice.com/api/v2/assets/5554?include=type_fields' # mk320 item with all fields
# $URL = 'https://greatgulfhelpdesk.freshservice.com/api/v2/assets?filter="asset_state: % 27IN%20STOCK%27%20"'