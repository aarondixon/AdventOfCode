[cmdletbinding()]
param(
    $inputfile = ".\sample.txt",
    [int]$expansion = 0
)

$text = get-content $inputfile

function IsLineValid {
    param(
        [string]$row,
        [int[]]$sizes
    )

    $groups = ($row -split "\.+" | where-object {$_.Length -gt 0})
    if($groups.count -ne $sizes.count) { return 0}

    for($g = 0; $g -lt $groups.count; $g++) {
        if($groups[$g].length -ne $sizes[$g]) {
            return 0
        }
    }

    write-verbose "!"
    return 1
}

function ProcessLine {
    param(
        [string]$row,
        [int[]]$sizes
    )

    Write-Verbose $row

    Write-Progress -ParentId 1 $row

    $q = $row.IndexOf("?")
    if($q -ge 0) {
        $normal = ProcessLine ($row.substring(0,$q) + "." + $row.substring($q+1)) $sizes
        $broken = ProcessLine ($row.substring(0,$q) + "#" + $row.substring($q+1)) $sizes
        return ($normal + $broken)
    } else {
        return IsLineValid ($row -join "") $sizes
    }
}

$cache = @{}

function Solve {
    param(
        [string]$row,
        [int[]]$sizes
    )

    write-verbose "  $row $sizes"

    $key = "$row $sizes"

    if($cache.containsKey($key)) {
        write-verbose "***CACHE*** $($cache[$key])"
        return $cache[$key]
    }

    if($sizes.count -eq 0) { 
        $result = ($row -notmatch "#")
        write-verbose "$result"
        $cache[$key] = $result
        return $result
    }

    $size,$sizes = $sizes
    $end = ($sizes | Measure-Object -Sum).Sum + $sizes.Count

    $total = 0
    $left = ""
    $max = $row.length - $end - $size +1

    write-verbose "  size: $size end: $end max: $max"
    for($i = 0; $i -lt $max) {
        if($left -eq "#") { break }

        $right = ($i + $size -eq $row.Length) ? "" : [string]$row[$i+$size]
        write-verbose "  right: $right"

        write-verbose "  check: $($row.Substring($i, $size))"

        if(($row.Substring($i, $size) -notmatch "\.") -and ($right -ne "#")) {
            $newrow = $row.Substring($i + $size + $right.length)
            write-verbose "  --> $newrow"
            $righttotal = Solve $newrow $sizes
            $total += $righttotal
        }
        $left = $row[$i]
        $i++
    }

    $cache[$key] = $total
    return $total
}

$count = 0
$sum = 0
foreach($l in $text) {
    $line = $l -split "\s+"
    if($expansion -gt 0) {
        $row = ($line[0]+"?")*($expansion -1) + $line[0]
        [int[]]$sizes = (($line[1]+",")*$expansion -split "," | where-object {$_.length -gt 0})
    } else {
        $row = $line[0]
        [int[]]$sizes = $line[1] -split ","
    }

    $Progress = @{
        Activity         = 'Analyzing'
        Status           = $row + " " + $sizes
        PercentComplete  = ($count / $text.length)*100
        Id               = 1
    }
    Write-Progress @Progress
    
    write-verbose ("="*($l.length))

    #$possibilities = ProcessLine $line[0] ($line[1] -split ",")
    $possibilities = Solve $row $sizes
    
    write-verbose "RESULT: $possibilities"
    $sum += $possibilities
    $count++
}

$sum

write-output $cache.Count