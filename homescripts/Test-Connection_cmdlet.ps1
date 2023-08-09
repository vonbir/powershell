


Test-Connection -ComputerName $server1 -Count 10 # default for count is 4

Test-Connection -ComputerName $server1 -Repeat # this one tests/pings the server repeatedly

Test-Connection -ComputerName $server1, google.com, facebook.com # pings multiple endpoints

Test-Connection -ComputerName $server1 -traceroute # not supported in older verison of PS but it does a trace route

Test-Connection -ComputerName $server1 -tcpport 80 # returns a boolean value (true/false)

# checks/validates the connection which can be useful when setting up remote sessions
if (Test-Connection -ComputerName $server1 -Count 1 -Quiet) {
    New-PSSession -ComputerName $server1 -Credential Administrator
} else {
    Write-Output "The connection could not connect to the machine $server1"
}




