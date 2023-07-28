Function getHTML {
    Param (
        [Parameter(Mandatory = $true)]  [String]$uri, # always need to pass in a URI for the API call
        [Parameter(Mandatory = $false)] [String]$method = "GET", # default is GET, can also be POST, DELETE etc. etc.
        [Parameter(Mandatory = $false)] [String]$data = $null # default is NULL, passing data to okta is tricky. Here is an example for a profile update: $data = '{"profile": {"firstName": "Delete","lastName": "Me"}}'
    )

    Begin {
        # headers needed to be passed in.  Authorization is the API token created in Okta and you're limited to its permissions
        $headers = @{}
        $headers["Authorization"] = "SSWS 00dfjaojf84j-jdfo9hjd94h987gfhDHNDdj638hd"
        #$headers["Authorization"] = "SSWS **** INSERT TOKEN HERE ****"  See next line for how it should look
        #$headers["Authorization"] = "SSWS 00dfjaojf84j-jdfo9hjd94h987gfhDHNDdj638hd"
        $headers["Accept"] = "application/json"
        $headers["Content-Type"] = "application/json"
    }

    Process {
        try {
            # to avoid issues we change the passed parameters based on the uri and method.  Here we add on the body (data) field only if we're NOT doing a GET (so a DELETE or a POST)
            # we also use body if we're going to do an 'activate'
            if ($method -ne "GET" -and $uri -inotmatch "activate") {
                $response = Invoke-RestMethod -Method $method -Uri $uri -Headers $headers -Body $data
                # pretty much used for all GET
            } else {
                $response = Invoke-RestMethod -Method $method -Uri $uri -Headers $headers
            }
            # checks the header for the api limit.  Sleeps the script if we're about to hit limit
            if ([int]$response.Headers['x-rate-limit-remaining'] -lt 2) {
                # minimum delay, just in case
                $apiDelay = 5
                # each header has the rate limit.  If we're about to hit it, we check the reset time and wait that long.
                $apiDelay = [math]::Round(($response.Headers['x-rate-limit-reset']) - (Get-Date -UFormat %s) - 18000) + 1
                Write-Host "API Limit reached...pausing for $($apiDelay) seconds"
                Start-Sleep -Seconds $apiDelay
            }
            # count is just used to keep track of how many times we've pestered Okta with an api call.
            $global:count += 1

            # sometimes queries run long...this spits out a progress report every 100th api call...just so we can watch the paint dry
            if ($global:count % 100 -eq 0) {
                Write-Host "$global:count queries processed"
            }

            # some API calls return nothing, so we handle those separately so as not to cause a panic
            if ($response.content.length -lt 3) {
                $htmlCode = $response.RawContent.Split("`n")[0].trim()
                if ($method -eq "DELETE") {
                    $oktaData = "$htmlCode - (Deletion Succesful)"
                } else {
                    # there are a [very] few outliers that are not DELETES and have no response...handling just in case
                    $oktaData = $($htmlCode) + " - (No content expected)"
                }
                # this code block runs for all successful queries (other than the aforementioned deletes).
            } else {

                # we convert the reply from Okta to JSON format.  Normally it comes back as a string.
                $oktaData = ConvertFrom-Json $response.content

                # Check to see if there is more data/we hit a return limit.  If the results are too long, Okta paginates it so we have to get the next chunk
                if ($response.Headers.link) {
                    # ok...admittingly this is ugly/overly complicated but here goes.  If there is pagination, the headers will contain a link value.
                    # The link value has 2 parts: 'self' (the url  was called) and 'next' which is what we need. So we split the link value, find the part that has 'next' in it and
                    # run the results through a regex that pulls out just the url we need.  Phew!  Horn tooting complete.  proceed
                    $after = ([Regex]::Matches($response.Headers.link.Split(",") -match 'rel="next"', '(?<=<)(.*?)(?=>)')).Value

                    # if we've found pagination and successfully parsed the link, we call the function again.  Engage Recursive Mode!
                    if ($after) {
                        # since there is recursion, we append the new results to the existing JSON and move to the next bit
                        $oktaData = $oktaData + (getHTML -uri $after -method $method)
                    }
                }
            }
            # we return the now JSON formatted results back to you
            return $oktaData
        }

        # ruh roh...we screwed up.
        catch [System.Net.WebException] {

            $resp = $_.Exception.Response

            # well..we didn't screw up here, but we did overload Okta and hit an API limit.  Technically there is code above here that should prevent this...but just in case...
            if ([int]$resp.StatusCode -eq 429) {

                # increase the delay seconds
                $global:delay += 5

                # welp...we've run up a 2 minute delay...clearly we broke Okta so let's quit while we're behind
                if ($global:delay -eq 120) {
                    Write-Host "Delay has reached 2 minutes.  Cancelling operations"
                    exit
                }

                # executes the current delay
                Write-Host "API Limit reached...pausing for $($global:delay) seconds"
                Start-Sleep -Seconds $global:delay

                # clear the error for fun
                $error.Clear()

                # reruns the current query and hopefully resume normal operations
                $oktaData = $oktaData + (getHTML -uri $uri -method $method)
            }

            # no error message?
            if ($resp -eq $null) {
                Write-Host $_.Exception
            }

            # prints out a nice error message for us
            else {
                $reqstream = $resp.GetResponseStream()
                $sr = New-Object System.IO.StreamReader $reqstream
                $body = $sr.ReadToEnd()

                # Okta is nice enough to print out an error code and an explanation.  Go here for more/same info: https://developer.okta.com/docs/reference/error-codes/
                Write-Host "Status: $([int]$resp.StatusCode) - $($resp.StatusCode)"
                Write-Host ($body.Split(",") -match "errorSummary")
            }

            # who the hell knows what we did wrong this time....meh
        } catch {
            Write-Host $_.Exception
        }
    }
}


<# EXAMPLES

Here we are populating the $data variable with profile info: firstName and lastName.
We then call the getHTML function with a POST and the $data passed in.
POST on a user + data = update the user's profile

$data = '{"profile": {"firstName": "Delete","lastName": "Menow"}}'
getHTML -Uri "https://kars4kids.okta.com/api/v1/users/00u1k10wnz3gf32NPnF1d8" -method 'POST' -data $data

------

This is a simple get on a specific user, id is hardcoded
getHTML -Uri "https://kars4kids.okta.com/api/v1/users/00u1k10wn344zggNPnF1d8"

------

This searches for all users who have a last name starting in y
getHTML -uri 'https://kars4kids.okta.com/api/v1/users?search=profile.lastName sw "y"'

------

This returns all Okta mastered groups
getHTML -uri 'https://kars4kids.okta.com/api/v1/groups?filter=type+eq+"OKTA_GROUP"'
------

This resets a user's MFA
getHTML -Uri "https://kars4kids.okta.com/api/v1/users/00u1k10F44fa2NPnF1d8/lifecycle/reset_factors" -method Post

------

OK - so enough with all the examples.  What do we do now?  Whatever you want....
Here is a real world example: Get user info on all people assigned to an application.
0oag3455g3dsdsD01d8 (Some AWS Random App.  I usually grab the IDs i'm targeting directly from the URL in my browser: https://kars4kids-admin.okta.com/admin/app/amazon_aws/instance/0oag3455g3dsdsD01d8/)
1) /api/v1/apps/0oag3455g3dsdsD01d8/users = gets all the users assigned to the app
2) loop through the users and get a link to their profile (using the ._links.user.href value)
3) get the user's info
4) print out what you want.

$users = getHTML -Uri "https://kars4kids.okta.com/api/v1/apps/0oag3455g3dsdsD01d8/users"
foreach ($user in $users) {
    $userInfo = getHTML -uri $user._links.user.href
    "{0},{1},{2},{3}" -f $userInfo.profile.firstName,$userInfo.profile.lastName,$userInfo.profile.email,$user._links.group.name
}

This yields results like:
Jane,Doe,jane.doe@kars4kids.com,Random_AWS_App_Group1
John,Doe,john.doe@kars4kids.com,Random_AWS_App_Group1
#>