
$array = 1..10

$newarray = @()

$array | ForEach-Object {

    [System.Management.Automation.PSCustomObject]
    $newarray += $_
}


$string = "
    test1,test2,test3,test4,test5
    test6,test7,test8,test9,test10
    "