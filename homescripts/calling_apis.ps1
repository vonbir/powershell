
# Invoke-RestMethod is perfect for quick APIs that have no special response information such as Headers or Status Codes,
# whereas Invoke-WebRequest gives you full access to the Response object and all the details it provides.

$uri = "http://randomuser.me/api"

# the Invoke-RestMethod cmdlet calls the Invoke-WebRequest and already converts the JSON data to PowerShell objects
# only gives you the results, it doesnt give you the status code/headers/raw content.
$RestMethod = Invoke-RestMethod -Uri $uri -Method Get

$RestMethod.results

# the Invoke-WebRequest cmdlet sends HTTP/HTTPS requests to a web page/service and returns JSON data and provides more
# information such as the headers/status codes/raw content as opposed to the RestMethod cmdlet.
$WebRequest = Invoke-WebRequest -Uri $uri -Method Get -UseBasicParsing

# do note you need to put in the parameter -UseBasicParsing if you don't have IE engine available.
$result = $WebRequest.Content | ConvertFrom-Json

$result.results