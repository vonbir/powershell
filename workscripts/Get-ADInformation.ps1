
$forestName = "greatgulf.biz"

$domains = Get-ADForest -Identity $forestName | Select-Object -ExpandProperty $domains

foreach ($domain in $domains) {
    Get-ADDomainController -Service $domain -Filter * | Select-Object Name, Domain, IPv4Address, Site
}

Get-ADDomain

