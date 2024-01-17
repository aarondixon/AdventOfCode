[cmdletbinding()]
param(
    $inputfile = "sample.txt"
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

<#

Rp + Rv * t1 = H1p + H1v * t1
Rv * t1 = (H1p + H1v * t1) - Rp
Rv = H1p / t1 + H1v - Rp / t1

Rp + Rv * t2 = H2p + H2v * t2

Rp + Rv * t3 = H3p + H3v * t3

#>

function Intersect([Hailstone]$h1,[Hailstone]$h2) {
        # Extracting components of the rays
    #$p1 = $Ray1.Point
    #$v1 = $Ray1.Velocity
    #$p2 = $Ray2.Point
    #$v2 = $Ray2.Velocity

    
    # Checking if the rays are parallel
    $crossProduct = [PSCustomObject]@{
        x = $h1.vy * $h2.vz - $h1.vz * $h2.vy
        y = $h1.vz * $h2.vx - $h1.vx * $h2.vz
        z = $h1.vx * $h2.vy - $h1.vy * $h2.vx
    }

    $crossProductMagnitude = [math]::Sqrt($crossProduct.x*$crossProduct.x + $crossProduct.y*$crossProduct.y + $crossProduct.z*$crossProduct.z)

    if ($crossProductMagnitude -lt 1e-10) {
        Write-Host "Rays are parallel, no intersection."
        return $null
    }

    # Calculating the intersection point
    $t = [PSCustomObject]@{
        x = (($h2.py - $h1.py) * $h2.vz - ($h2.pz - $h1.pz) * $h2.vy) / $crossProductMagnitude
        y = (($h2.pz - $h1.pz) * $h2.vx - ($h2.px - $h1.px) * $h2.vz) / $crossProductMagnitude
        z = (($h2.px - $h1.px) * $h2.vy - ($h2.py - $h1.py) * $h2.vx) / $crossProductMagnitude
    }

    $intersectionPoint = [PSCustomObject]@{
        x = $h1.x + $t.x * $h1.vx
        y = $h1.y + $t.y * $h1.vy
        z = $h1.z + $t.z * $h1.vz
    }

    #write-verbose "$intersectionPoint"

    return $intersectionPoint,$t
}

$hail = [system.collections.generic.queue[Hailstone]]::new()

$count = 1
foreach($line in (Get-Content $inputfile)) {
    $position = ($line -split "@")[0].trim() -split ","
    $velocity = ($line -split "@")[1].trim() -split ","

    $hail.enqueue([Hailstone]::new($count,$position[0].trim(),$position[1].trim(),$position[2].trim(),$velocity[0].trim(),$velocity[1].trim(),$velocity[2].trim()))
    $count++
}

$correct = [Hailstone]::new(99,24,13,10,-3,1,2)
$count = 0
while($hail.count -gt 0) {
    $h1 = $hail.dequeue()
    write-verbose "H$($h1.id) = $($h1.px) $($h1.py) $($h1.pz)"
    <#foreach($h2 in $hail) {
        #get t for each intersection, extrapolate to where t = 0, return coordinates at t = 0
        write-verbose "  H$($h2.id) = $($h2.px) $($h2.py) $($h2.pz)"
        $result = Intersect $h1 $h2
        if($null -ne $result) {
            $x = $result[0].x
            $y = $result[0].y
            $z = $result[0].z
            $t = $result[1]
            write-verbose "    INT = $x $y $z"        
            $count++
            write-verbose "$($h1.id) intersects with $($h2.id) at ($x,$y,$z) at $t"
        }
    }#>
    $result = Intersect $h1 $correct
    write-verbose "$($result[0]) $($result[1])"
}

$count