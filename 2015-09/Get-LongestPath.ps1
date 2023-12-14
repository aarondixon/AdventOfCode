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

$longest = 0
foreach($start in $Paths.Keys) {
    $distance = 0
    [System.Collections.Generic.List[string]]$citiestovisit = $Paths.Keys | Where-Object {$_ -ne $start}
    $city = $start
    while($citiestovisit.Count -gt 0) {
        $path = $Paths[$city].GetEnumerator() | Where-Object {$_.Name -in $citiestovisit} | Sort-Object Value -Descending | Select-Object -First 1
        $distance += $path.Value
        $citiestovisit.Remove($path.Name) | Out-null
        $city = $path.Name
    }

    if($longest -eq 0 -or $distance -gt $longest) {
        $longest = $distance
    }
}

$longest