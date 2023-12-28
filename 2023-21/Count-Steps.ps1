[cmdletbinding()]
param(
    $inputfile = ".\sample.txt",
    $targetsteps = 64,
    [switch]$pause
)

Import-Module ..\Modules\GridWork.psm1

Class Tile {
    [int]$row
    [int]$col
    [System.Collections.Generic.list[string]]$neighbors

    Tile($r,$c) {
        $this.row = $r
        $this.col = $c
        $this.neighbors = [system.collections.generic.list[string]]::new()
    }
}

$text = Get-Content $inputfile
$grid = @()
$tiles = @{}
$coordmods = (-1,0),(0,1),(1,0),(0,-1)

$start = ""
#build grid, creating tiles for each . and noting the start
for($r = 0; $r -lt $text.count; $r++) {
    $grid += ,$text[$r].ToCharArray()
    for($c = 0; $c -lt $grid[$r].count; $c++) {
        if($grid[$r][$c] -ne "#") {
            if($grid[$r][$c] -eq 'S') { $start = "$r,$c" }
            $tiles["$r,$c"] = [Tile]::new($r,$c)
        }
    }
}

$maxr = $grid.count - 1
$maxc = $grid[0].count - 1

#build quad tree
foreach($coord in $tiles.Keys) {
    foreach($mod in $coordmods) {
        $newr = $tiles[$coord].row + $mod[0]
        $newc = $tiles[$coord].col + $mod[1]

        if($newr -ge 0 -and $newr -le $maxr -and $newc -ge 0 -and $newc -le $maxc) {
            if($grid[$newr][$newc] -ne "#") { $tiles[$coord].neighbors.add("$newr,$newc")}
        }
    }   
}

#step
#$positions = [system.collections.generic.list[string]]::new()
#$positions.add($start)
$Q = [System.Collections.Generic.Queue[string]]::new()
$Q.Enqueue($start)
Write-Verbose "START $start"
for($s = 1; $s -le $targetsteps; $s++) {
    $Qt = [System.Collections.Generic.Queue[string]]::new()
    write-verbose "STEP $s ($($Q.count) tiles)"
    while($Q.count -gt 0) {
        $pos = $Q.Dequeue()
        #write-verbose "  $pos -> $($tiles[$pos].neighbors)"
        foreach($n in $tiles[$pos].neighbors) {
            if(-not $Qt.Contains($n)) { $Qt.Enqueue($n) }
        }
    }
    $Q = $Qt
    if($pause) { read-host }
}

($Q | Select-Object -Unique).Count