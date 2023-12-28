[cmdletbinding()]
param(
    [int[]]$x1,
    [int[]]$y1,
    [int[]]$x2,
    [int[]]$y2
)
Class Point {
    [int]$x
    [int]$y

    Point($x,$y) {
        $this.x = $x
        $this.y = $y
    }

    [string]Print() {
        return "$($this.x),$($this.y)"
    }
}
function OnSegment([Point]$p,[Point]$q,[Point]$r) {
    if(($q.x -le [math]::max($p.x,$r.x)) -and ($q.x -ge [math]::min($p.x,$r.x)) -and ($q.y -le [math]::max($p.y,$r.y)) -and ($q.y -ge [math]::min($p.y,$r.y))) {
        return $true
    }

    return $false
}

function Orientation([Point]$p,[Point]$q,[Point]$r) {
    $val = (($q.y - $p.y) * ($r.x - $q.x)) - (($q.x - $p.x) * ($r.y - $q.y))
    if($val -gt 0) { return 1 } elseif($val -lt 0) { return 2} else { return 0}
}

$a1 = [Point]::New($x1[0],$x1[1])
$b1 = [Point]::New($y1[0],$y1[1])
$a2 = [Point]::New($x2[0],$x2[1])
$b2 = [Point]::New($y2[0],$y2[1])

write-verbose $a1.print()
write-verbose $b1.print()
write-verbose $a2.print()
write-verbose $b2.print()

if($a1.x -eq $b1.x -and $a1.y -eq $b1.y) {
    if(OnSegment $a2 $a1 $b2) { return $true }
}

if($a2.x -eq $b2.x -and $a2.y -eq $b2.y) {
    if(OnSegment $a1 $a2 $b1) { return $true }
}

$d1 = Orientation $a1 $b1 $a2
$d2 = Orientation $a1 $b1 $b2
$d3 = Orientation $a2 $b2 $a1
$d4 = Orientation $a2 $b2 $b1

write-verbose "$d1 $d2 $d3 $d4"

write-verbose ("** BRICK {0} ({1},{2}-{3},{4}) INTERSECTS WITH BRICK {5} ({6},{7}-{8},{9}) ?" -f $this.id,$a1.x,$a1.y,$b1.x,$b1.y,$brick.id,$a2.x,$a2.y,$b2.x,$b2.y)        

if($d1 -ne $d2 -and $d3 -ne $d4) { write-verbose "    ** YES"; return $true }

if($d1 -eq 0 -and (OnSegment $a1 $a2 $b1)) { write-verbose "    ** YES"; return $true }

if($d2 -eq 0 -and (OnSegment $a1 $b2 $b1)) { write-verbose "    ** YES"; return $true }

if($d3 -eq 0 -and (OnSegment $a2 $a1 $b2)) { write-verbose "    ** YES"; return $true }

if($d4 -eq 0 -and (OnSegment $a2 $b1 $b2)) { write-verbose "    ** YES"; return $true }

write-verbose "    XX NO"; 
return $false