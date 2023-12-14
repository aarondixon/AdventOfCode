[cmdletbinding()]
param(
    $inputfile = ".\sample.txt",
    $cycles = 1
)

function Transpose { # swap rows and columns. unfortunately, powershell doesn't have a quick/easy way to do this natively
    param(
        [string[]]$rows
    )

    $cols = @("") * $rows[0].Length
    foreach($row in $rows) {
        for($r = 0; $r -lt $row.length; $r++) {
            $cols[$r] += $row[$r]
        }
    }

    return $cols
}


function Tilt { # perform the tilt in the specified direction
    param(
        [string[]]$rows,
        [string[]]$cols,
        [string]$dir
    )

    $set = @()
    $rev = $false
    switch($dir) { # determine if we'll be working with rows or columns, and which way we'll be removing empty space (down/right if rev = true, up/left if rev = false)
        "n" { $set = $cols; $rev = $false } 
        "s" { $set = $cols; $rev = $true }
        "e" { $set = $rows; $rev = $true }
        "w" { $set = $rows; $rev = $false }
    }

    $newset = @() # initialize array to hold new rows or columns

    foreach($item in $set) { #iterate through each row or column
        write-verbose "  $item"

        $newsecs = @()
        $secs = $item -split "#"
        #split row or column into sections between #s (and edges)
        for($s = 0; $s -lt $secs.count; $s++) {
            $sec = $secs[$s] -replace "\.","" #remove all . in section
            write-verbose "    $($secs[$s]) -> $sec"
            if($rev) {
                #back-fill section with . to the left of rocks (rocks "shift" right/down)
                $newsecs += "." * ($secs[$s].length - $sec.length) + $sec
            } else {
                #back-fill section with . to the right of rocks (rocks "shift" left/up)
                $newsecs += $sec + "." * ($secs[$s].length - $sec.length)
            }
        }

        #add modified row or column to new collection
        $newset += $newsecs -join "#"
    }

    $newrows = @()
    $newcols = @()
    switch($dir) { #transpose rows or columns as necessary
        "n" { $newrows = Transpose $newset; $newcols = $newset }
        "s" { $newrows = Transpose $newset; $newcols = $newset }
        "e" { $newrows = $newset; $newcols = Transpose $newset }
        "w" { $newrows = $newset; $newcols = Transpose $newset }
    }    
    
    #return modified grid in rows and columns (not "rebuilding" grid because it'll just have to be broken into rows/columns again for the next tilt)
    return @{Rows = $newrows; Cols = $newcols}
}

$text = (Get-Content $inputfile)

$dirs = "n","w","s","e"

$rows = $text
$cols = Transpose $rows

#find when repeats, do $cycles % $repeat, calc weight (for sample, $repeat = 7 (6 +1?), weight = 64)

$results = @{}
$repeat = 0
$first = -1
# perform cycles until a loop is detected. once loop is found, return loop length and first occurrence (as offset)
for($c = 1; $c -le $cycles; $c++) {
    write-progress -Activity "Running Cycles" -Status "Cycle $c" -PercentComplete ($c / $cycles * 100) -id 1
    Write-Verbose "%%% CYCLE $c %%%"
    for($i = 0; $i -lt 4; $i++) {
        write-progress -Activity "Tilting" -status "Tilt $($dirs[$i % 4])" -PercentComplete ($i / 4 * 100) -ParentId 1
        Write-Verbose "  *** DIR $($dirs[$i % 4]) ***"
        $grid = Tilt $rows $cols $dirs[$i % 4]
        $rows = $grid.Rows
        $cols = $grid.Cols
    }

    $key = $rows -join "`n"
    if($results.ContainsKey($key)) { #if we've seen this grid before
        $first = $results[$key] # get cycle # of first occurrence
        $loop = $c - $results[$key] # loop length is current cycle minus cycle # of first occurrence
        write-verbose "First: $first, Loop: $loop"
        break
    } else { # we haven't seen this grid before, save cycle #
        $results[$key] = $c
    }
}

if($first -ge 0) { # if we found a loop
    $target = $first + (($cycles - $first) % $loop) # calculate cycle # of the grid that would have been at the total cycle count, considering the offset of the first occurrence
    foreach($key in ($results.GetEnumerator() | where-object {$_.Value -eq $target })) { #search through hashtable to find grid at target cycle #
        $rows = ($key.Name -split "`n") # get rows of grid at target cycle #
    }
}

write-output "`n$($rows -join "`n")"


# get weight on north beams
$totalweight = 0
for($r = 0; $r -lt $rows.count; $r++) { #go through each row
    $compressed = ($rows[$r] -replace "\.","") -replace "#","" #remove . and # to get number of rocks at row
    write-verbose "$($rows.count - $r) = $compressed"
    $totalweight += $compressed.Length * ($rows.count - $r) # multiply rock count by row weight (row count - current row), add to total
    
}

$totalweight