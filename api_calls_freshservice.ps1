

$APIKey = 'yXlSTOK9dxuazwqNl4A'
$EncodedCredentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(('{0}:{1}' -f $APIKey, $null)))

$HTTPHeaders = @{}
$HTTPHeaders.Add('Authorization', ('Basic {0}' -f $EncodedCredentials))
# $URL = 'https://greatgulfhelpdesk.freshservice.com/api/v2/assets?include=type_fields'
# $URL = 'https://greatgulfhelpdesk.freshservice.com/api/v2/assets?order_by=created_at' # sort by created by
# $URL = 'https://greatgulfhelpdesk.freshservice.com/api/v2/assets?per_page=100;include=type_fields' # include all fields and 100 per page
# $URL = 'https://greatgulfhelpdesk.freshservice.com/api/v2/assets/5554?include=type_fields' # mk320 item with all fields
$URL = 'https://greatgulfhelpdesk.freshservice.com/api/v2/assets?filter="asset_state:%27IN%20STOCK%27%20"'

$Params = @{
    Method      = 'Get'
    Uri         = $URL
    Headers     = $HTTPHeaders
    ContentType = 'application/json'
}

$Status = Invoke-RestMethod @Params

# $status.assets

$qty = $status.asset.type_fields.quantity_16000332716


#
$APIKey = 'yXlSTOK9dxuazwqNl4A'
$EncodedCredentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(('{0}:{1}' -f $APIKey, $null)))
$HTTPHeaders = @{}
$HTTPHeaders.Add('Authorization', ('Basic {0}' -f $EncodedCredentials))
$URL = 'https://greatgulfhelpdesk.freshservice.com/api/v2/assets\5554?include=type_fields'

$Params = @{
    Method      = 'Get'
    Uri         = $URL
    Headers     = $HTTPHeaders
    ContentType = 'application/json'
}

$Status = Invoke-RestMethod @Params

$status.asset | Select-Object name, @{n = "Quantity"; e = { $_.type_fields.quantity_16000332716 } }, @{n = "AssetState"; e = { $_.type_fields.state_16000332716 } }, updated_at