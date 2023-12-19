[cmdletbinding()]
param(
    $inputfile = ".\sample.txt"
)

class Beam {
    [int]$row
    [int]$col
    [char]$direction
    [bool]$active

    Beam ($r, $c, $d) {
        $this.row = $r
        $this.col = $c
        $this.direction = $d
        $this.active = $true
    }
}

function Get-Energized {
    param(
        [Beam[]]$beams,
        $grid
    )

    write-verbose $beams.count

    $energized = @{}

    while(($beams | Where-Object {$_.active -eq $true}).Count -gt 0) {
        write-verbose "CYCLE"
        foreach($beam in ($beams | where-object {$_.active -eq $true})) {
            write-verbose "  BEAM ($($beam.row),$($beam.col)) $($beam.direction)"
            if(-not $energized.ContainsKey("$($beam.row),$($beam.col)")) {
                $energized["$($beam.row),$($beam.col)"] = @()
            } elseif($energized["$($beam.row),$($beam.col)"] -contains $beam.direction) {
                #if the tile is already energized and the beam is going the same direction, deactivate beam
                $beam.active = $false
                continue
            }
    
            $energized["$($beam.row),$($beam.col)"] += $beam.direction #add beam's direction to energized tile
    
            #consider beam's location on the grid
            write-verbose "    Grid $($grid[$beam.row][$beam.col])"
            switch($grid[$beam.row][$beam.col]) {
                '\' { #if \, change beam's direction by 90 degrees
                    switch($beam.direction) {
                        'n' { $beam.direction = 'w'}
                        'e' { $beam.direction = 's'}
                        's' { $beam.direction = 'e'}
                        'w' { $beam.direction = 'n'}
                    }
                }
    
                '/' { #if /, change beam's direction by 90 degrees
                    switch($beam.direction) {
                        'n' { $beam.direction = 'e'}
                        'e' { $beam.direction = 'n'}
                        's' { $beam.direction = 'w'}
                        'w' { $beam.direction = 's'}
                    }
                }
    
                '-' { #if -, split beam horizontally if coming from n or s (change direction by 90 degrees and create new beam in opposite direction)
                    if($beam.direction -eq 'n' -or $beam.direction -eq 's') {
                        $beam.direction = 'e'
                        if($beam.col -gt 0) {
                            $beams += [Beam]::new($beam.row,$beam.col-1,'w')
                        }
                    }
                }
    
                '|' { #if |, split beam vertically if coming from e or w (change direction by 90 degrees and create new beam in opposite direction)
                    if($beam.direction -eq 'e' -or $beam.direction -eq 'w') {
                        $beam.direction = 's'
                        if($beam.row -gt 0) {
                            $beams += [Beam]::new($beam.row-1,$beam.col,'n') 
                        }
                    }
                }
            }
    
            # consider beam's direction, increase/decrease row/col appropriately. if beam is at edge, deactivate
            switch($beam.direction) {
                'n' {
                    if($beam.row -gt 0) {
                        $beam.row--
                    } else {
                        $beam.active = $false
                    }
                }
    
                'e' {
                    if($beam.col -lt $grid[$beam.row].count-1) {
                        $beam.col++
                    } else {
                        $beam.active = $false
                    }
                }
    
                's' {
                    if($beam.row -lt $grid.Count-1) {
                        $beam.row++
                    } else {
                        $beam.active = $false
                    }
                }
    
                'w' {
                    if($beam.col -gt 0) {
                        $beam.col--
                    } else {
                        $beam.active = $false
                    }
                }
            }
        }
    }
     
    #$energized
    <#
    $energizedgrid = $grid.clone()
    foreach($tile in $energized.GetEnumerator()) {
        write-verbose $tile.key
        $coord = $tile.key -split ","
        $energizedgrid[$coord[0]][$coord[1]] = "#"
    }
    
    foreach($row in $energizedgrid) {
        write-verbose ($row -join "")
    }
    #>
    return $energized.Keys.Count    
}

$grid = @()
foreach($line in (Get-Content $inputfile)) {
    $grid += ,$line.ToCharArray()
}

$max = $grid.count - 1

$results = @()
$results += Get-Energized @([Beam]::new(0,0,'e')) $grid 
$results += Get-Energized @([Beam]::new(0,0,'s')) $grid 
$results += Get-Energized @([Beam]::new(0,$max,'w')) $grid
$results += Get-Energized @([Beam]::new(0,$max,'s')) $grid
$results += Get-Energized @([Beam]::new($max,0,'e')) $grid
$results += Get-Energized @([Beam]::new(0,$max,'n')) $grid
$results += Get-Energized @([Beam]::new($max,$max,'e')) $grid
$results += Get-Energized @([Beam]::new($max,$max,'n')) $grid

for($i = 1; $i -lt $max; $i++) {
    write-progress -Activity "Working" -PercentComplete (((4*$i) / (4*($max+1)))*100)
    $results += Get-Energized @([Beam]::new(0,$i,'s')) $grid
    $results += Get-Energized @([Beam]::new($max,$i,'n')) $grid
    $results += Get-Energized @([Beam]::new($i,0,'e')) $grid
    $results += Get-Energized @([Beam]::new($i,$max,'w')) $grid
}

$results.count
$results | Measure-object -Maximum | Select-Object Maximum