[cmdletbinding()]
param(
    $text = (Get-Content "input.txt")
)

$races = @()
$times = @()
$distances = @()
$times = ($text[0] -split ":")[1].trim() -split "\s+"
$distances = ($text[1] -split ":")[1].trim() -split "\s+"
if($times.count -ne $distances.count) {
    write-error "Invalid input -- unequal number of times and distances"
    exit
} else {
    for($i = 0; $i -lt $times.count; $i++) {
        $races += @{time=[int]$times[$i]; distance=[int]$distances[$i]}
    }
}

$product = 1
foreach($race in $races) {
    write-verbose "race! time: $($race.time); record: $($race.distance)"
    $ways = 0
    $optimal = [math]::floor($race.time / 2)
    $peak = [math]::floor([math]::sqrt($race.distance))
    for($d = $peak; $d -gt 0; $d--) {
        if(($race.time - $d) * $d -le $race.distance) { break }
        #if($race.distance % $d -eq 0) { break }
    }

    write-verbose "optimal: $optimal"
    write-verbose "record: $d"
    
    if($race.time % 2 -eq 0) { $ways-- }
    $ways += ($optimal * 2) - ($d * 2)
    write-verbose "  $ways ways"
    $product = $product * $ways
}

$product