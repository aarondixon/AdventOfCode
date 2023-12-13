[cmdletbinding()]
param(
    $inputfile = ".\sample.txt"
)

$cache = @{}

function FindReflections {
    param(
        [string[]]$set,
        [int]$multiplier
    )

    $key = $set -join "`n"

    if($cache.ContainsKey($key)) {
        return $cache[$key] * $multiplier
    }

    if($set.count -le 1) {
        $cache[$key] = 0
        return 0
    }

    write-verbose "Comparing $($set[0]) and $($set[1])"
    if($set[0] -eq $set[1]) {
        Write-Verbose "  MATCH"
        $cache[$key] = 1 * $multiplier
        return 1 * $multiplier
    }

    $count = 0
    for($i = 1; $i -lt $set.count - 1; $i++) {
        write-verbose "Comparing $($set[$i]) and $($set[$i+1])"
        if($set[$i] -eq $set[$i+1]) { #found potential point of reflection
            Write-Verbose "  MATCH"
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
                write-verbose "  MATCH ON $i"
                $count = $i + 1
                break
            }
        }
    }

    $cache[$key] = $count * $multiplier
    return $count * $multiplier

}

$sum = 0
$nl = [System.Environment]::NewLine
foreach($grid in (Get-Content $inputfile -raw) -split "$nl$nl") {
    $grid = $grid -split "$nl"
    write-verbose "Grid :`n$($grid -join "`n")"
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

    $result = 0
    if($rows.count -lt $cols.count) {
        Write-Verbose "Checking Rows"
        $result = FindReflections $rows 100
        Write-Verbose "  RESULT: $result"
        if($result -gt 0) {
            $sum += $result
            continue
        }
        Write-Verbose "Checking Cols"
        $result = FindReflections $cols 1
        Write-Verbose "  RESULT: $result"
    } else {
        Write-Verbose "Checking Cols"
        $result = FindReflections $cols 1
        Write-Verbose "  RESULT: $result"
        if($result -gt 0) {
            $sum += $result
            continue
        }
        Write-Verbose "Checking Rows"
        $result = FindReflections $rows 100
        Write-Verbose "  RESULT: $result"
    }

    $sum += $result
}

$sum