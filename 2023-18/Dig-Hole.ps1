[cmdletbinding()]
param(
    $inputfile = ".\sample.txt"
)

Class Block {
    [int]$row
    [int]$col
    [int]$depth
    [string]$color

    Block($r,$c,$depth,$color) {
        $this.color = $color
        $this.row = $r
        $this.col = $c
        $this.depth = $depth        
    }

    Block($r,$c,$depth) {
        $this.row = $r
        $this.col = $c
        $this.depth = $depth
    }

}

Class Edge {
    [int]$row_s
    [int]$row_e
    [int]$col_s
    [int]$col_e
    [string]$color

    Edge($r1,$c1,$r2,$c2,$col) {
        $this.color = $col
        if($r1 -eq $r2) {
            $this.row_s = $r1
            $this.row_e = $r2
        } elseif($r1 -lt $r2) {
            $this.row_s = $r1+1
            $this.row_e = $r2-1
        } else {
            $this.row_s = $r2+1
            $this.row_e = $r1-1
        }

        if($c1 -eq $c2) {
            $this.col_s = $c1
            $this.col_e = $c2
        } elseif($c1 -lt $c2) {
            $this.col_s = $c1+1
            $this.col_e = $c2-1
        } else {
            $this.col_s = $c2+1
            $this.col_e = $c1-1
        }
    }
}

function IsInPoly {
    param(
        [int]$r,
        [int]$c,
        $polygon
    )

    $isInside = $false
    $n = $polygon.count

    for($i = 0; $i -lt $n; $i++) {
        $j = ($i + 1) % $n
        $ri,$ci = $polygon[$i]
        $rj,$cj = $polygon[$j]

        $intersect = (($ri -lt $r -and $rj -ge $r) -or ($rj -lt $r -and $ri -ge $r)) -and ($ci + ($r - $ri) / ($rj - $ri) * ($cj - $ci) -lt $c)        

        if($intersect) { $isInside = -not $isInside }
    }

    return $isInside
}

$coords = @{}
$edges = @()
$vertices = @()

$r = 0
$c = 0
$coords["$r,$c"] = [Block]::new($r,$c,1)

foreach($line in (Get-Content $inputfile)) {
    $inst = $line -split " "
    $dir = $inst[0]
    $len = [int]$inst[1]
    $col = $inst[2].trimstart("(").trimend(")")

    $rmod = 0
    $cmod = 0
    switch($dir) {
        "R" { $cmod = 1; $edges += [Edge]::new($r,$c,$r,$c+$len,$col) }
        "D" { $rmod = 1; $edges += [Edge]::new($r,$c,$r+$len,$c,$col) }
        "L" { $cmod = -1; $edges += [Edge]::new($r,$c,$r,$c-$len,$col) }
        "U" { $rmod = -1; $edges += [Edge]::new($r,$c,$r-$len,$c,$col) }
    }

    $vertices += ,($r,$c)
    for($i = 1; $i -le $len; $i++) {
        $r += $rmod
        $c += $cmod
        $coords["$r,$c"] = [Block]::new($r,$c,1,$col)
    }
    $vertices += ,($r,$c)
}

$maxr = ($coords.Values.row | measure-object -Maximum).Maximum
$minr = ($coords.Values.row | measure-object -minimum).Minimum
$maxc = ($coords.Values.col | measure-object -Maximum).Maximum
$minc = ($coords.Values.col | measure-object -minimum).Minimum
$offr = 0 - $minr
$offc = 0 - $minc

Write-Verbose "Row: ($minr - $maxr) Col: ($minc - $maxc) Offset: ($offr,$offc)"

$volume = 0
write-verbose ($coords.Values.depth | Measure-object -sum).sum
write-verbose ($edges.count)

$edgesonrow = @{}
foreach($edge in $edges) {
    for($r = $edge.row_s; $r -le $edge.row_e; $r++) {
        if(-not $edgesonrow["$r"]) {
            $edgesonrow["$r"] = @()
        }
        $edgesonrow["$r"] += $edge.col_s
    }
}

$grid = [string[,]]::new($maxr+$offr+1,$maxc+$offc+1)
for($r = $minr; $r -le $maxr; $r++) {
    for($c = $minc; $c -le $maxc; $c++) {
        #write-verbose "($r,$c)"
        if($coords["$r,$c"].depth -gt 0) {
            $grid[($r+$offr),($c+$offc)] = "#"
        } else {
            # write-verbose "$r = $($edgesonrow["$r"])"
            $edgesright = ($edgesonrow["$r"] | Where-Object {$_ -gt $c}).count
            $edgesleft = ($edgesonrow["$r"] | Where-Object {$_ -lt $c}).count
            # write-verbose $edgesright
            
            #if($edgesright % 2 -ne 0 -and ($c -gt $minc) -and $edgesleft -gt 0) {
            if(IsInPoly $r $c $vertices) {
                $coords["$r,$c"] = [Block]::new($r,$c,1)
                $grid[($r+$offr),($c+$offc)] = "*"
            } else {
                $grid[($r+$offr),($c+$offc)] = "."
            }
        }
    }
}
<#
foreach($edge in $edges) {
    for($r = $edge.row_s; $r -le $edge.row_e; $r++) {
        for($c = $edge.col_s; $c -le $edge.col_e; $c++) {
            $grid[($r+$offr),($c+$offc)] = "%"
        }
    }
}
#>
$lines = @()
for($r = 0; $r -le $maxr + $offr; $r++) {
    $line = ""
    for($c = 0; $c -le $maxc + $offc; $c++) {
        $line += $grid[$r,$c]
    }
    #write-verbose $line
    $lines += $line
}


$lines | out-file .\output.txt
$lines
$volume = ($coords.Values.depth | Measure-object -sum).sum

$volume