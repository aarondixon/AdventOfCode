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


$totalarea = 0
foreach($p in $packages) {
    $area = (($p.l * $p.w),($p.w * $p.h),($p.h * $p.l))
    $surfacearea = 2*($area | Measure-Object -Sum).Sum 
    $bonus = ($area | Measure-Object -Minimum).Minimum
    write-verbose "$surfacearea + $bonus = $($surfacearea + $bonus)"
    $totalarea += $surfacearea + $bonus
}
$totalarea