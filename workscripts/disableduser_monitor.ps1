


Param (
    $location = $PSScriptRoot,
    $serversfile = "$location\servers.txt"
)

begin {
    if ($false -eq (Test-Path $serversfile)) {
        throw "servers.txt file not found at location : $serversfile"
    }

}

process {
    Get-Content $serversfile
}

end {

}
$userlist = Import-Csv C:\Users\brylle.purificacion\Downloads\zoomus_user_template_2023-10-10.csv

$disabledusers = Get-ADUser -Filter * -Properties mail | where {$_.Enabled -eq $false} | select name,mail

foreach ($user in $userlist){

    if ($user.email -    $disabledusers.mail){
        $user.email
    }
}