[cmdletbinding()]
param(
    $inputfile = ".\sample.txt"
)

#realized in the first part that all I was really doing was reporting the area, so got rid of all the
#traversal and just found vertices and calculated area. The tricky part was realizing that the border
#width was not included in the area calculation, so I had to add 1/2 of the border to the end of every
#edge, or the perimeter / 2 + 1 to the total

function GetPolygonArea($polygon) {
    $n = $polygon.Count
    $area = 0

    for ($i = 0; $i -lt $n - 1; $i++) {

        $area += $polygon[$i][0] * $polygon[$i+1][1] - $polygon[$i+1][0] * $polygon[$i][1]
    }

    $area += $polygon[$n-1][0] * $polygon[0][1] - $polygon[0][0] * $polygon[$n-1][1]

    $area = [Math]::Abs($area) / 2
    return $area
}


$vertices = @()

$r = 0
$c = 0
$vertices += ,($r,$c)
$perimeter = 0
foreach($line in (Get-Content $inputfile)) {
    $inst = $line -split " "
    $dir = $inst[0]
    $len = [int]$inst[1]
    $col = $inst[2].trimstart("(#").trimend(")")

    $len = [uint32]"0x$($col.substring(0,5))"
    $dir = $col.substring(5)
    $perimeter += $len
    $rmod = 0
    $cmod = 0
    switch($dir) {
        "0" { $cmod = 1} #R
        "1" { $rmod = 1} #D
        "2" { $cmod = -1} #L
        "3" { $rmod = -1} #U
    }

    $r = $r + $rmod * $len
    $c = $c + $cmod * $len
    $vertices += ,($r,$c)
}

(GetPolygonArea $vertices) + $perimeter / 2 + 1