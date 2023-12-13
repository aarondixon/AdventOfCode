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

    $key = "$row $sizes"
    #pull result from cache if it exists (MUCH MUCH FASTER)
    if($cache.containsKey($key)) {
        write-verbose "***CACHE*** $($cache[$key])"
        return $cache[$key]
    }

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

    #pull result from cache if it exists (MUCH MUCH FASTER)
    if($cache.containsKey($key)) {
        write-verbose "***CACHE*** $($cache[$key])"
        return $cache[$key]
    }

    #if no sizes specified, return 1 possibility as long as row doesn't contain #
    if($sizes.count -eq 0) { 
        $result = ($row -notmatch "#")
        write-verbose "$result"
        $cache[$key] = $result
        return $result
    }

    #prune the first size from list
    $size,$sizes = $sizes

    $total = 0
    $left = "" #initialise to "" because it'll be the start of the row

    #calculate maximum bound of search range based on sizes specified, I think to limit search to possible range of current size we're testing 
    #(got help on this one, don't fully understand how the below determines that)
    $max = $row.length - (($sizes | Measure-Object -Sum).Sum + $sizes.Count) - $size +1

    write-verbose "  size: $size end: $end max: $max"

    for($i = 0; $i -lt $max; $i++) {

        if($left -eq "#") { break } #exit loop is left-most character of test range is # because it'll mean a new group

        #get right-most character of test range ("" if end of row)
        $right = ($i + $size -eq $row.Length) ? "" : [string]$row[$i+$size]
        write-verbose "  right: $right"

        write-verbose "  check: $($row.Substring($i, $size))"

        #if the test range doesn't include any number of . AND the right-most character is not #
        if(($row.Substring($i, $size) -notmatch "\.") -and ($right -ne "#")) {
            #get section of row starting at i and going to the end of the size we're testing, plus the additional right character if it's not the end of the row
            $newrow = $row.Substring($i + $size + $right.length)
            write-verbose "  --> $newrow"
            $righttotal = Solve $newrow $sizes #recurse using new test string and remaining sizes
            $total += $righttotal
        }
        $left = $row[$i] #select next character as left-most
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

    $possibilities = ProcessLine $row $sizes
    #$possibilities = Solve $row $sizes
    
    write-verbose "RESULT: $possibilities"
    $sum += $possibilities
    $count++
}

$sum

write-output $cache.Count