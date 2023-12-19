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

$grid = @()
$energized = @{}
foreach($line in (Get-Content $inputfile)) {
    $grid += ,$line.ToCharArray()
}

$beams = @()
$beams += [Beam]::new(0,0,'e')
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

foreach($tile in $energized.GetEnumerator()) {
    write-verbose $tile.key
    $coord = $tile.key -split ","
    $grid[$coord[0]][$coord[1]] = "#"
}

foreach($row in $grid) {
    write-output ($row -join "")
}

$energized.Keys.Count