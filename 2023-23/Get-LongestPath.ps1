[cmdletbinding()]
param(
    $inputfile = ".\sample.txt"
)

$forest = @()
foreach($line in (Get-Content $inputfile)) {
    $forest += ,$line.ToCharArray()
}
$lines = [int]($forest.count) - 1 

$start = (0,($forest[0] -join "").IndexOf("."))
$end = ($lines,($forest[$lines] -join "").IndexOf("."))

function walk($curr,$path) {
    write-verbose "$curr : $($path.count) ($($forest[$curr[0]][$curr[1]])))"
    $path += "$($curr[0]),$($curr[1])"

    if($curr[0] -eq $end[0] -and $curr[1] -eq $end[1]) { 
        write-verbose "FOUND END: $($path.count)"
        return $path.count
    }

    while($forest[$curr[0]][$curr[1]] -in ('v','^','<','>')) {
        switch($forest[$curr[0]][$curr[1]]) {
            "V" { $curr[0]++ }
            "^" { $curr[0]-- }
            "<" { $curr[1]-- }
            ">" { $curr[1]++ }       
        }

        $path += "$($curr[0]),$($curr[1])"
    }

    <#
    $lines = ""
    for($r = 0; $r -lt $forest.count; $r++) {
        $line = ""
        for($c = 0; $c -lt $forest[$r].count; $c++) {
            if($path -contains "$r,$c") {
                $line += "O"
            } else {
                $line += $forest[$r][$c]
            }
        }
        $lines += "`n$line"
    }
    write-verbose ($lines -join "`n")
    start-sleep -Milliseconds 100
    #>

    $longest = 0
    $modcoords = @((-1,0),(0,-1),(1,0),(0,1))
    foreach($mod in $modcoords) {
        $r = $curr[0] + $mod[0]
        $c = $curr[1] + $mod[1]
     
        if($r -ge 0 -and $c -ge 0 -and $forest[$r][$c] -ne '#' -and ("v>^<".indexof($forest[$r][$c]) -ne $modcoords.indexof($mod))) {
            if($path -notcontains "$r,$c") {
                $count = walk ($r,$c) (@() + $path)
                if($count -gt $longest) { $longest = $count}
            }
        }
    }

    return $longest
}

(walk $start @()) - 1