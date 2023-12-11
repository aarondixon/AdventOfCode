[cmdletbinding()]
param(
    $text = (Get-Content "sample.txt"),
    $expansion = 2
)

# expand universe
#   find cols with no galaxies (count -ne '.')
#   insert blank col for each
#   repeat for rows

# get galaxies
#   iterate through universe
#   get indices of each galaxy for each row to get coords
#     b = "A","D","B","D","C","E","D","F" 
#     (0..($b.Count-1)) | where {$b[$_] -eq 'D'}
#   add ID, hashtable

# find paths between each pair (even slope)

[System.Collections.Generic.List[string]]$rows = @("") * $text.length
[System.Collections.Generic.List[string]]$cols = @("") * $text[0].length

$expansion--

$galaxies = @{}
$g = 1
for($r = 0; $r -lt $text.length; $r++) {
    $rows[$r] = $text[$r].ToString()
    for($c = 0; $c -lt $text[0].length; $c++) {
        $cols[$c] += $text[$r][$c]
        if($text[$r][$c] -eq "#") { 
            $galaxies[$g] = @{original = @($r,$c); new = @($r,$c)}
            $g++
        }
    }
}


for($c = 0; $c -lt $rows[0].length; $c++) {
    #$row += $rows[$r][$c]
    if($cols[$c].indexOf("#") -lt 0) {
        #$row += "."
        foreach($k in $galaxies.keys) {
            if($galaxies[$k].original[1] -gt $c) {
                write-verbose "Expanding at COLUMN $c, affecting GALAXY $k ($($galaxies[$k].new[1] + $expansion))"
                $galaxies[$k].new[1] += $expansion
            }
        }
    }
}

for($r = 0; $r -lt $rows.count; $r++) {
    #$universe.Add($row.ToCharArray())
    if($rows[$r].indexOf("#") -lt 0) {
        #$universe.Add($row.ToCharArray())
        foreach($k in $galaxies.Keys) {
            if($galaxies[$k].original[0] -gt $r) { 
                write-verbose "Expanding at ROW $r, affecting GALAXY $k ($($galaxies[$k].new[0] + $expansion))"
                $galaxies[$k].new[0] += $expansion
            }
        }
    }
}

#$galaxies
$paths = @()
$sum = 0
foreach($i in $galaxies.Keys) {
    foreach($j in ($galaxies.keys | Where-Object {$_ -lt $i})) {
        $g1 = $galaxies[$i].new
        $g2 = $galaxies[$j].new
        #if(($g1[0] - $g2[0]) / ($g1[1] - $g2[1]))
        $length = [math]::abs($g2[0] - $g1[0]) + [math]::abs($g2[1] - $g1[1])
        #write-verbose "Galaxy $i ($($g1 -join ",")) Galaxy $j ($($g2 -join ",")) = $length"
        #$paths += @{Galaxy1 = $i; Galaxy2 = $j; Path = $length}
        $sum += $length
    }
}

#$paths.Path | measure-object -sum | select sum
$sum