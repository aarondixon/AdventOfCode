[cmdletbinding()]
param(
    $inputfile = ".\sample.txt"
)

$cache = @{}

function FindReflections {
    param(
        [string[]]$set,
        [int]$multiplier,
        [int]$firstresult = -1
    )

    $result = 0

    $key = $set -join "`n"

    
    if($cache.ContainsKey($key)) {
        $result = $cache[$key]
        if($result -ne $firstresult) {
            return $result
        }
    }

    if($set.count -le 1) {
        $cache[$key] = 0
        return 0
    }

    #write-verbose "Comparing $($set[0]) and $($set[1])"
    if($set[0] -eq $set[1]) {
        $result = 1 * $multiplier
        $cache[$key] = $result
        if($firstresult -ne $result) {
            Write-Verbose "  REFLECTION VERIFIED ON 1"
            return $result
        } else {
            write-verbose "  SAME AS FIRST ($result = $firstresult)"
        }
    }

    $count = 0
    for($i = 1; $i -lt $set.count - 1; $i++) {
        #write-verbose "Comparing $($set[$i]) and $($set[$i+1])"
        if($set[$i] -eq $set[$i+1]) { #found potential point of reflection
            Write-Verbose "  REFLECTION CANDIDATE: $i | $($i+1)"
            $j = $i-1
            $k = $i + 2
            $valid = $true
            while($j -ge 0 -and $k -lt $set.count -and $valid) {
                write-verbose "  Comparing $($set[$j]) and $($set[$k])"
                if($set[$j] -ne $set[$k]) {
                    $valid = $false
                }
                $j--
                $k++
            }

            if($valid) {
                $count = $i + 1
                $result = $count * $multiplier
                if($result -ne $firstresult) {
                    write-verbose "  REFLECTION VERIFIED ON $i"
                    $cache[$key] = $result
                    return $result
                } else {
                    write-verbose "  SAME AS FIRST ($result = $firstresult)"
                }
            }
        }
    }

    return 0
}

function Toggle($copy,$i) {
    $str = $copy
    if($str[$i] -eq ".") { $n = "#" } else {$n = "."}
    return $str.remove($i,1).insert($i,$n)
}

$badresults = @()
$results = @()
$nl = [System.Environment]::NewLine
$text = (Get-Content $inputfile -raw) -split "$nl$nl"
foreach($grid in $text) {
    $grid = $grid -split "$nl"
    write-verbose "Grid $count `n$($grid -join "`n")"
    write-verbose "  Rows: $($grid.length)"
    Write-verbose "  Cols: $($grid[0].length)"
    $rows = @("") * $grid.length
    $cols = @("") * $grid[0].length
    for($r = 0; $r -lt $grid.length; $r++) {
        $rows[$r] = $grid[$r].ToString()
        for($c = 0; $c -lt $grid[0].length; $c++) {
            $cols[$c] += $grid[$r][$c]
        }
    }

    $firstresult = 0
    if($rows.count -lt $cols.count) {
        Write-Verbose "Checking Rows"
        $firstresult = FindReflections $rows 100
        if($firstresult -eq 0) {
            Write-Verbose "Checking Cols"
            $firstresult = FindReflections $cols 1
        }
    } else {
        Write-Verbose "Checking Cols"
        $firstresult = FindReflections $cols 1
        if($firstresult -eq 0) {
            Write-Verbose "Checking Rows"
            $firstresult = FindReflections $rows 100
        }
    }
    write-verbose "FIRST RESULT: $firstresult"

    

    $result = 0
    for($r = 0; $r -lt $rows.count; $r++) {
        for($c = 0; $c -lt $cols.count; $c++) {
            $newrows = $rows.Clone()
            $newcols = $cols.Clone()
            $newrows[$r] = (Toggle $rows[$r] $c)
            $newcols[$c] = (Toggle $cols[$c] $r)

            write-verbose ("="*$newrows[0].length)
            write-verbose ("Toggling $r,$c`n" + ($newrows -join "`n"))

            if($newrows.count -lt $newcols.count) {
                Write-Verbose "Checking Rows"
                $result = FindReflections $newrows 100 $firstresult
                if($result -eq 0) {
                    Write-Verbose "Checking Cols"
                    $result = FindReflections $newcols 1 $firstresult
                }
            } else {
                Write-Verbose "Checking Cols"
                $result = FindReflections $newcols 1 $firstresult
                if($result -eq 0) {
                    Write-Verbose "Checking Rows"
                    $result = FindReflections $newrows 100 $firstresult
                }
            }
            if($result -gt 0) { break }
        }
        if($result -gt 0) { break }
    }

    if($result -eq 0 -or $result -eq $firstresult) { $badresults += ($grid -join "`n") }
    $results += $result
    write-verbose "RESULT: $result"
}

($results | Measure-object -sum).Sum

foreach($r in $badresults) {
    write-output "$r`n"
}