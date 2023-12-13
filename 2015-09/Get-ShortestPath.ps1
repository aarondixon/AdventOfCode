[cmdletbinding()]
param(
    $inputfile = ".\sample.txt"
)

$Paths = @{}

foreach($line in (Get-Content $inputfile)) {
    $cities = ($line -split "=").Trim()[0]
    $dist = [int]($line -split "=").Trim()[1]

    $start = ($cities -split "to").Trim()[0]
    $end = ($cities -split "to").Trim()[1]

    if(-not $Paths.ContainsKey($start)) {
        $Paths[$start] = @{}
    }

    $Paths[$start][$end] = $dist

    if(-not $Paths.ContainsKey($end)) {
        $Paths[$end] = @{}
    }

    $Paths[$end][$start] = $dist
}

$shortest = 0
foreach($start in $Paths.Keys) {
    $distance = 0
    $citiestovisit = $Paths.Keys | Where-Object {$_ -ne $start}
    $city = $start


}
