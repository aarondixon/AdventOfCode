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
    write-verbose "race!"
    $ways = 0
    $hold = [math]::floor($race.time / 2)
    while ($hold * ($race.time - $hold) -gt $race.distance) {
        write-verbose "  hold $hold, travel $($hold * ($race.time - $hold))"
        $ways += 1
        $hold--
    }
    $ways = $ways * 2
    if($race.time % 2 -eq 0) { $ways-- }
    write-verbose "  $ways ways"
    $product = $product * $ways
}

$product