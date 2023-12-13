[cmdletbinding()]
param(
    $text = (Get-Content "sample.txt")
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

for($r = 0; $r -lt $text.length; $r++) {
    $rows[$r] = $text[$r].ToString()
    for($c = 0; $c -lt $text[0].length; $c++) {
        $cols[$c] += $text[$r][$c]
    }
}

[System.Collections.Generic.List[char[]]]$universe = @()
for($r = 0; $r -lt $rows.count; $r++) {
    $row = ""
    for($c = 0; $c -lt $rows[$r].length; $c++) {
        $row += $rows[$r][$c]
        if($cols[$c].indexOf("#") -lt 0) {
            $row += "."
        }
    }

    $universe.Add($row.ToCharArray())
    if($row.indexOf("#") -lt 0) {
        $universe.Add($row.ToCharArray())
    }
}

$galaxies = @{}
$g = 1
for($r = 0; $r -lt $universe.count; $r++) {
    for($c = 0; $c -lt $universe[$r].length; $c++) {
        if($universe[$r][$c] -eq "#") {
            $galaxies[$g] = ($r,$c)
            $g++
        }
    }
}


foreach($l in $universe) {
    write-output [string]$l
}

$galaxies
$paths = @()
foreach($i in $galaxies.Keys) {
    foreach($j in ($galaxies.keys | Where-Object {$_ -lt $i})) {
        $g1 = $galaxies[$i]
        $g2 = $galaxies[$j]
        #if(($g1[0] - $g2[0]) / ($g1[1] - $g2[1]))
        $length = [math]::abs($g2[0] - $g1[0]) + [math]::abs($g2[1] - $g1[1])
        write-verbose "Galaxy $i ($($g1 -join ",")) Galaxy $j ($($g2 -join ",")) = $length"
        $paths += @{Galaxy1 = $i; Galaxy2 = $j; Path = $length}
    }
}

$paths.Path | measure-object -sum | select-object sum