[cmdletbinding()]
param(
    $inputfile = "input.txt",
    $digits = "0".."9",
    $emptychar = "."
)

$text = get-content $inputfile

function SymbolPresent($test) {
    for($x = 0; $x -lt $test.length; $x++) {
        if(($test[$x] -ne $emptychar) -and ($digits -notcontains $test[$x].tostring())) { return $true}
    }

    return $false
}

function SymbolAdjacent($above, $current, $below) {
    if($above) {
        if(SymbolPresent -test $above) { return $true }
    }

    if(SymbolPresent -test $current) { return $true  }

    if($below) {
        if(SymbolPresent -test $below) { return $true }
    }

    return $false
}
<#
Find numbers in each line
- 
Detect if adjacent to symbol
Add to sum
#>

write-verbose "$($text.count) lines"
$sum = 0
for($l = 0; $l -lt $text.count; $l++) {
    $line = $text[$l]
    $nums = @()
    Write-Verbose "Line $l"
    for($i = 0; $i -lt $line.length; $i++) {
        $num = ""
        $len = 0
        if($digits -contains $line[$i].tostring()) {
            $len = 1
            if(($i + $len) -lt $line.length) {
                while($digits -contains $line[$i+$len].tostring()) {
                    $len += 1
                    if($i+$len -ge $line.length) { break }
                }
            }
            #check for adjacent symbols
            if($i -gt 0) { $startcol = $i - 1 } else { $startcol = $i }
            if(($i + $len) -lt ($line.length - 1)) { $endcol = $i + $len + 1 } else { $endcol = $i + $len }
            $above = $null
            $below = $null
            if($l -gt 0) { $above = $text[$l - 1].substring($startcol, ($endcol - $startcol)) }
            if($l -lt ($text.count -1)) { $below = $text[$l+1].substring($startcol, ($endcol - $startcol)) }
            $current = $line.substring($startcol, ($endcol - $startcol))
            write-verbose "  $above"
            write-verbose "  $current"
            write-verbose "  $below"
            if(SymbolAdjacent -above $above -current $current -below $below) { write-verbose "  --[VALID]--"; $num = $line.substring($i,$len)} else { write-verbose "  -----------"}
        }
        if($num -ne "") { $nums += $num; $sum += [int]$num}
        $i = $i + $len
    }
    write-verbose " Numbers: $($nums -join "; ")"
}

$sum