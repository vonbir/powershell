
$reportObject = [PSCustomObject]@{
  "Column1" = "Value1"
  "Column2" = "Value2"
  "Column3" = "Value3"
}

$report = $reportObject | ConvertTo-Csv -NoTypeInformation -Delimiter ","

$body1 = [PSCustomObject][Ordered]@{
  "@type"      = "AdaptiveCard"
  "@context"   = "http://schema.org/extensions"
  "summary"    = ""
  "themeColor" = "0078D7"
  "title"      = "INVENTORY UPDATE: ($date)"
  "text"       = "$report"
}

$body2 = ' {
    "@context": "https://schema.org/extensions",
    "@type": "MessageCard",
    "themeColor": "0072C6",
    "title": "Using Microsoft Teams",
    "text": "Please make sure to read the User Guide first.",
    "potentialAction": [

      {
        "@type": "OpenUri",
        "name": "Request Office 365 Group",
        "targets": [
          { "os": "default", "uri": "https://teams.microsoft.com/l/entity/81fef3a6-72aa-4648-a763-de824aeafb7d/_djb2_msteams_prefix_316372079?context=%7B%22subEntityId%22%3Anull%2C%22channelId%22%3A%2219%3A96f7bce5c6e2472a8f6e896ef0e4f875%40thread.skype%22%7D&groupId=d622b046-74e2-46a4-a1c6-63411f915464&tenantId=5176709f-3f1f-4e44-a034-277655f7629c" }
        ]
      }
    ]
  } '

$JSONBody = ConvertTo-Json $body1 -Depth 100

$parameters = @{
  "URI"         = "https://greatbuildersolutions.webhook.office.com/webhookb2/cec7e207-dcbe-46af-ab09-0fada3fa2281@6b152703-09ac-40ef-87cb-89f5be3bb6aa/IncomingWebhook/a9ec88022cfa44f9a2b7f2e14e286a32/a258c296-5ad3-49a6-91cf-b271bd53fb2d"
  "Method"      = "POST"
  "Body"        = $body2
  "ContentType" = "application/json"
}

Invoke-RestMethod @parameters

