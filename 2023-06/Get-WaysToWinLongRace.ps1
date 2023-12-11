[cmdletbinding()]
param(
    $text = (Get-Content "input.txt")
)

$time=[int64](($text[0] -split ":")[1] -replace "\s+","")
$dist=[int64](($text[1] -split ":")[1] -replace "\s+","")
#$time = 30
#$dist = 200

#find factors of $dist
#only consider sets that all factors are less than $time
#ways = $max - $largestfactor; if $time is even, $ways--

write-verbose "Race Time: $time; Record Distance: $dist"

$optimal = [math]::floor($time / 2)
$peak = [math]::floor([math]::sqrt($dist))
for($d = $peak; $d -gt 0; $d--) {
    if(($time - $d) * $d -le $dist) { break}
}

write-verbose "optimal: $optimal"
write-verbose "record: $d"
$ways = ($optimal * 2) - ($d * 2)
if($time % 2 -eq 0) { $ways-- }

$ways