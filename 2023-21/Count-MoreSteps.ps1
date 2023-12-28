[cmdletbinding()]
param(
    $inputfile = ".\sample.txt",
    $targetsteps = 64,
    [switch]$pause
)

#Import-Module ..\Modules\GridWork.psm1

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
write-verbose "$maxr $maxc"

#build quad tree
foreach($coord in $tiles.Keys) {
    foreach($mod in $coordmods) {
        $newr = $tiles[$coord].row + $mod[0]
        $newc = $tiles[$coord].col + $mod[1]

        <#if($newr -lt 0) { $newr = $maxr }
        if($newr -gt $maxr) { $newr = 0 }
        if($newc -lt 0) { $newc = $maxc }
        if($newc -gt $maxc) { $newc = 0 }#>
        if($newr -ge 0 -and $newr -le $maxr -and $newc -ge 0 -and $newc -le $maxc) {
            #if($grid[$newr][$newc] -ne "#") { $tiles[$coord].neighbors.add("$newr,$newc")}
            $tiles[$coord].neighbors.add("$newr,$newc")
        } 
    }   
}

#step
$Q = [System.Collections.Generic.Queue[string]]::new()
$Q.Enqueue($start)
$visited = [system.collections.generic.hashset[string]]::new()
for($r = 0; $r -lt $grid.count; $r++) {
    for($c = 0; $c -lt $grid[$r].count; $c++) {
        if($grid[$r][$c] -eq "#") { [void]$visited.add("$r,$c") }
    }
}

$reachable = [system.collections.generic.hashset[string]]::new()
$odd = ($targetsteps % 2 -ne 0)
Write-Verbose "START $start"
for($s = 0; $s -lt $targetsteps+1; $s++) {
    $Qt = [System.Collections.Generic.Queue[string]]::new()
    write-verbose "STEP $s ($($Q.count) tiles)"
    while($Q.count -gt 0) {
        $pos = $Q.Dequeue()
        [void]$visited.add($pos)
        if(($s % 2 -ne 0) -eq $odd) { [void]$reachable.add($pos) }
        foreach($mod in $coordmods) {
            $newr = [int]($pos -split ",")[0] + $mod[0]
            $newc = [int]($pos -split ",")[1] + $mod[1]

            if($newr -lt 0 -or $newr -gt $maxr -or $newc -lt 0 -or $newc -gt $maxc) { continue }            
            if($visited.contains("$newr,$newc") ) { continue }

            if($Qt.contains("$newr,$newc")) { continue }
            $Qt.Enqueue("$newr,$newc")
        }
    }
    $Q = $Qt
    if($pause) { read-host }
}

foreach($pos in $reachable) {
    $r = [int]($pos -split ",")[0]
    $c = [int]($pos -split ",")[1]
    $grid[$r][$c] = "O"
}


$reachable.count

#($Q | Select-Object -Unique).Count