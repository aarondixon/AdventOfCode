[cmdletbinding()]
param(
    $inputfile = ".\sample.txt"
)

Class Point {
    [int]$x
    [int]$y

    Point($x,$y) {
        $this.x = $x
        $this.y = $y
    }
}

class Coord {
    [int]$x
    [int]$y
    [int]$z

    Coord($x,$y,$z) {
        $this.x = $x
        $this.y = $y
        $this.z = $z
    }

    Coord([string]$coords) {
        $xyz = $coords.trim() -split ","
        $this.x = $xyz[0]
        $this.y = $xyz[1]
        $this.z = $xyz[2]
    }

    [bool]IsBelow([coord]$target) {
        return ($target.x -eq $this.x -and $target.y -eq $this.y -and $target.z -gt $this.z)
    }
}

class Brick : System.IComparable {
    $id
    [Coord]$start
    [Coord]$end
    
    Brick ($id,$x1,$y1,$z1,$x2,$y2,$z2) {
        $this.id = $id
        $this.start = [Coord]::New($x1,$y1,$z1)
        $this.end = [Coord]::New($x2,$y2,$z2)
    }

    Brick($id,$xyz1,$xyz2) {
        $this.id = $id
        $this.start = [Coord]::New($xyz1)
        $this.end = [Coord]::New($xyz2)
    }

    Settle($amount) {
        $this.start.z -= $amount
        $this.end.z -= $amount
    }

    [bool]OrientX() {
        return ($this.start.x -ne $this.end.x)
    }

    [bool]OrientY() {
        return ($this.start.y -ne $this.end.y)
    }

    [bool]OrientZ() {
        return ($this.start.z -ne $this.end.z)
    }

    [bool]Intersects([brick]$brick) {
        function OnSegment([Point]$p,[Point]$q,[Point]$r) {
            if(($q.x -le [math]::max($p.x,$r.x)) -and ($q.x -ge [math]::min($p.x,$r.x)) -and ($q.y -le [math]::max($p.y,$r.y)) -and ($q.y -ge [math]::min($p.y,$r.y))) {
                return $true
            }

            return $false
        }

        function Orientation([Point]$p,[Point]$q,[Point]$r) {
            $val = (($q.y - $p.y) * ($r.x - $q.x)) - (($q.x - $p.x) * ($r.y - $q.y))
            if($val -gt 0) { return 1 } elseif($val -lt 0) { return 2} else { return 3}
        }

        $a1 = [Point]::New($this.start.x,$this.start.y)
        $b1 = [Point]::New($this.end.x,$this.end.y)
        $a2 = [Point]::New($brick.start.x,$brick.start.y)
        $b2 = [Point]::New($brick.end.x,$brick.end.y)

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
    }

    [bool]IsBelow([Brick]$brick) {
        if($this.end.z -ge $brick.start.z) { return $false }

        return $this.Intersects($brick)
    }

    [bool]IsAbove([Brick]$brick) {
        if($this.end.z -le $brick.start.z) { return $false }

        return $this.Intersects($brick)
    }

    [string]Print() {
        return ("{0},{1},{2} - {3},{4},{5}" -f $this.start.x,$this.start.y,$this.start.z,$this.end.x,$this.end.y,$this.end.z)
    }

    [int]CompareTo([object]$other)
    {
        return $this.start.z.CompareTo($other.start.z)
    }
}

function PrintTower($bricks) {
    $maxX = $bricks | Select-Object -ExpandProperty end | Measure-Object -Property x -Maximum | Select-Object -ExpandProperty Maximum
    $maxY = $bricks | Select-Object -ExpandProperty end | Measure-Object -Property y -Maximum | Select-Object -ExpandProperty Maximum
    $maxZ = $bricks | Select-Object -ExpandProperty end | Measure-Object -Property z -Maximum | Select-Object -ExpandProperty Maximum

    $gridX = [object[,]]::new($maxZ+1,$maxX+1)
    $gridY = [object[,]]::new($maxZ+1,$maxY+1)

    foreach($brick in $bricks) {
        for($z = $brick.start.z; $z -le $brick.end.z; $z++) {
            for($x = $brick.start.x; $x -le $brick.end.x; $x++) {
                $gridX[$z,$x] = $brick.id
            }
            for($y = $brick.start.y; $y -le $brick.end.y; $y++) {
                $gridY[$z,$y] = $brick.id
            }
        }
    }

    $OutX = ""
    $OutY = ""
    for($z = $maxZ;$z -ge 0; $z--) {
        $OutX += "$z "
        for($x = 0; $x -le $maxX; $x++) {
            if($gridX[$z,$x]) { 
                $OutX += $gridX[$z,$x]
            } else {
                $OutX += "."
            }
        }
        $OutY += "$z "
        for($y = 0; $y -le $maxY; $y++) {
            if($gridY[$z,$y]) {
                $OutY += $gridY[$z,$y]
            } else {
                $OutY += "."
            }
        }

        $OutX += "`n"
        $OutY += "`n"
    }

    Write-Output $OutX
    Write-Output "------------"
    Write-Output $OutY
}

$bricks = [system.collections.generic.list[Brick]]::New()

$count = 1
foreach($line in (Get-Content $inputfile)) {
    if(($line -split " ").count -gt 0) {
        $id = ($line -split " ")[1]
        $coords = ($line -split " ")[0]
    } else {
        $id = $count
        $coords = $line
    }
    $bricks.Add([Brick]::new($id,($coords -split "~")[0],($coords -split "~")[1]))
    $count++
}

$bricks = $bricks | Sort-Object

PrintTower $bricks

for($b = 0; $b -lt $bricks.count; $b++) {
    Write-Progress -Activity "Settling Tower" -PercentComplete ($b / $bricks.count * 100)
    write-verbose "Evaluating brick $($bricks[$b].id) ($($bricks[$b].Print()))"
    $bricksBelow = $bricks | Where-Object { $_.IsBelow($bricks[$b]) } | Sort-Object
    write-verbose "  Bricks below:"
    foreach($bb in $bricksBelow) { write-verbose "    $($bb.id)"}
    if($bricksBelow.count -eq 0) {
        $newZ = 1
    } else {
        $newZ = $bricksBelow[$bricksBelow.count -1].start.z + 1
    }

    $bricks[$b].Settle($bricks[$b].start.z - $newZ)
}

PrintTower $bricks

$count = 0
for($b = 0; $b -lt $bricks.Count; $b++) {
    Write-Progress -Activity "Checking Bricks" -PercentComplete ($b / $bricks.count * 100)
    Write-Verbose "Checking brick $($bricks[$b].id) ($($bricks[$b].Print()))"
    $bricksAbove = $bricks | Where-Object {$_.start.z -eq $bricks[$b].end.z + 1 -and $_.Intersects($bricks[$b])}
    $canremove = $true
    foreach($brick in $bricksAbove) {
        write-verbose "  Checking brick $($brick.id) above"
        $bricksBelow = $bricks | Where-Object { ($_.end.z -eq $brick.start.z - 1) -and ($_.id -ne $bricks[$b].id) -and $_.Intersects($brick) }
        write-verbose "$($bricksBelow.id)"
        if($bricksBelow.count -eq 0) { $canremove = $false; break; }
    }

    if($canremove) { $count++ }
}

#$bricks
$count