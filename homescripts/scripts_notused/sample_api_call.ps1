

$APIKey = 'yXlSTOK9dxuazwqNl4A'
$EncodedCredentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(('{0}:{1}' -f $APIKey, $null)))
$HTTPHeaders = @{}
$HTTPHeaders.Add('Authorization', ('Basic {0}' -f $EncodedCredentials))
$URL = 'https://greatgulfhelpdesk.freshservice.com/api/v2/automations/3/rules'

$Params = @{
    Method      = 'Get'
    Uri         = $URL
    Headers     = $HTTPHeaders
    ContentType = 'application/json'
}

$Status = Invoke-RestMethod @Params

