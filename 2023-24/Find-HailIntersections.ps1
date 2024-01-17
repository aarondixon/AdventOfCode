[cmdletbinding()]
param(
    $inputfile = "sample.txt",
    $min = 200000000000000,
    $max = 400000000000000
)

class Hailstone {
    [int64]$px
    [int64]$py
    [int64]$pz
    [int64]$vx
    [int64]$vy
    [int64]$vz
    $id

    Hailstone($id,$px,$py,$pz,$vx,$vy,$vz) {
        $this.px = $px
        $this.py = $py
        $this.pz = $pz
        $this.vx = $vx
        $this.vy = $vy
        $this.vz = $vz
        $this.id = $id
    }
}

function Intersect([Hailstone]$h1,[Hailstone]$h2,[switch]$threed) {
    if(-not $threed) {
        #$h1.px + $h1.vx * $i1 = $h2.px + $h2.vx * $i2
        #$h1.py + $h1.py * $i1 = $h2.py + $h2.vy * $i2

        #|h1.vx, -h2.vx| * |s| = |h2.px - h1.px|
        #|h1.vy, -h2.vy|   |t|   |h2.py - h1.py|

        <#
        $M = new-object 'int64[,]' 2,2
        $A = new-object 'int64[,]' 2,2
        $M[0,1] = $h1.vx
        $M[0,1] = -1 * $h2.vx
        $M[1,0] = $h1.vy
        $M[1,1] = -1 * $h2.vy

        $D = $M[0,0] * $M[1,1] - $M[0,1] * $M[1,0]
        if($D -eq 0) {
            return $null #no intersection
        }

        [int64[]]$b = ($h2.px - $h1.px, $h2.py - $h1.py)

        $A[0,0] = $M[1,1] * (1/$D)
        $A[0,1] = $M[0,1] * (1/$D) * -1
        $A[1,0] = $M[1,0] * (1/$D) * -1
        $A[1,1] = $M[0,0] * (1/$D)

        $s = $b[0] * $A[0,0] + $b[0] * $A[1,0]
        $t = $b[1] * $A[0,1] + $b[1] * $A[1,1]

        $x = $h1.px + $s * $h1.vx
        $y = $h1.py + $s * $h1.py
        #>

        #p = as + ad * u
        #dx = bs.x - as.x
        #dy = bs.y - as.y
        #det = bd.x * ad.y - bd.y * ad.x
        #u = (dy * bd.x - dx * bd.y) / det
        #v = (dy * ad.x - dx * ad.y) / det

        $dx = $h2.px - $h1.px
        $dy = $h2.py - $h1.py
        $det = ($h2.vx * $h1.vy) - ($h2.vy * $h1.vx)
        if($det -eq 0) { return $null }

        $u = ($dy * $h2.vx - $dx * $h2.vy) / $det
        $x = $h1.px + $u * $h1.vx
        $y = $h1.py + $u * $h1.vy

        return ($x,$y)
    }
}

$hail = [system.collections.generic.queue[Hailstone]]::new()

$count = 1
foreach($line in (Get-Content $inputfile)) {
    $position = ($line -split "@")[0].trim() -split ","
    $velocity = ($line -split "@")[1].trim() -split ","

    $hail.enqueue([Hailstone]::new($count,$position[0].trim(),$position[1].trim(),$position[2].trim(),$velocity[0].trim(),$velocity[1].trim(),$velocity[2].trim()))
    $count++
}

$count = 0
while($hail.count -gt 0) {
    $h1 = $hail.dequeue()
    write-verbose "H1 = $($h1.px) $($h1.py)"
    foreach($h2 in $hail) {
        write-verbose "  H2 = $($h2.px) $($h2.py)"
        $result = Intersect $h1 $h2
        if($null -ne $result) {
            [int64]$x = $result[0]
            [int64]$y = $result[1]
            write-verbose "    INT = $x $y"
            if($x -ge $min -and $x -le $max -and $y -ge $min -and $y -le $max) {
                if( (($h1.vx -ge 0 -and $x -ge $h1.px) -or ($h1.vx -lt 0 -and $x -lt $h1.px)) -and 
                    (($h1.vy -ge 0 -and $y -ge $h1.py) -or ($h1.vy -lt 0 -and $y -lt $h1.py)) -and
                    (($h2.vx -ge 0 -and $x -ge $h2.px) -or ($h2.vx -lt 0 -and $x -lt $h2.px)) -and
                    (($h2.vy -ge 0 -and $y -ge $h2.py) -or ($h2.vy -lt 0 -and $y -lt $h2.py))) {
                        $count++
                        write-verbose "$($h1.id) intersects with $($h2.id) at ($x,$y)"
                }
            }
        }
    }
}

$count