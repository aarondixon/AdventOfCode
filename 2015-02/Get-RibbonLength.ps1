[cmdletbinding()]
param(
    $text = (Get-Content "sample.txt")
)

$packages = @()
foreach($l in $text) {
    $valid = $l -match "(\d+)x(\d+)x(\d+)"
    if($valid) {
        $packages += @{l = [int]$Matches[1]; w = [int]$Matches[2]; h = [int]$Matches[3]}
    }
}


$totalribbon = 0
foreach($p in $packages) {
    $shortest = ($p.l,$p.w,$p.h | sort-object)[0..1]
    $totalribbon += 2*$shortest[0] + 2*$shortest[1] + $p.l * $p.w * $p.h
}
$totalribbon