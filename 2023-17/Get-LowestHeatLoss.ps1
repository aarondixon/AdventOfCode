[cmdletbinding()]
param(
    $inputfile = ".\sample.txt",
    $max = 3
)

$city = @()
foreach($line in (Get-Content $inputfile)) {
    $city += ,($line.ToCharArray() | foreach-object { [int16]::parse($_)})
}

$pos = (0,0)
$maxr = $city.count - 1
$maxc = $city[$city.count - 1].count - 1
write-verbose "Max R=$maxr | Max C=$maxc"
[char]$dir = 'e'
$heat= @{}
$count = 0
$totalheat = 0
$visited = @("0,0")
while(-not ($pos[0] -eq $maxr -and $pos[1] -eq $maxc)) {
    write-verbose "($($pos -join ","))"
    switch($dir) {
        'e' {
            if($pos[0] -eq 0 -or $visited -contains "$($pos[0]-1),$($pos[1])") { $heat.Remove('n') } else { $heat['n'] = $city[$pos[0]-1][$pos[1]] + 10}
            if($pos[0] -eq $maxr -or $visited -contains "$($pos[0]+1),$($pos[1])") { $heat.Remove('s') } else {$heat['s'] = $city[$pos[0]+1][$pos[1]]}
            if($pos[1] -eq $maxc -or $count -eq $max -or $visited -contains "$($pos[0]),$($pos[1]+1)") { $heat.remove('e') } else { $heat['e'] =$city[$pos[0]][$pos[1]+1] }
            $heat.Remove('w')
        }

        's' {
            $heat.Remove('n')
            if($pos[0] -eq $maxr -or $count -eq $max -or $visited -contains "$($pos[0]+1),$($pos[1])") { $heat.remove('s')} else { $heat['s'] = $city[$pos[0]+1][$pos[1]]}
            if($pos[1] -eq $maxc -or $visited -contains "$($pos[0]),$($pos[1]+1)" ) { $heat.remove('e') } else { $heat['e'] = $city[$pos[0]][$pos[1]+1] }
            if($pos[1] -eq 0 -or $visited -contains "$($pos[0]),$($pos[1]-1)" ) { $heat.remove('w')} else {$heat['w'] = $city[$pos[0]][$pos[1]-1] + 10}
        }

        'w' {
            if($pos[0] -eq 0 -or $visited -contains "$($pos[0]-1),$($pos[1])") { $heat.remove('n')}  else { $heat['n'] = $city[$pos[0]-1][$pos[1]] + 10 }
            if($pos[0] -eq $maxr -or $visited -contains "$($pos[0]+1),$($pos[1])") { $heat.remove('s')} else {$heat['s'] = $city[$pos[0]+1][$pos[1]] }
            $heat.Remove('e')
            if($pos[1] -eq 0 -or $count -eq $max -or $visited -contains "$($pos[0]),$($pos[1]-1)") { $heat.remove('w')} else { $heat['w'] = $city[$pos[0]][$pos[1]-1] }
        }

        'n' {
            if($pos[0] -eq 0 -or $count -eq $max -or $visited -contains "$($pos[0]-1),$($pos[1])") { $heat.remove('n')} else {$heat['n'] = $city[$pos[0]-1][$pos[1]]}
            $heat.Remove('s')
            if($pos[1] -eq $maxc -or $visited -contains "$($pos[0]),$($pos[1]+1)") { $heat.remove('e') } else { $heat['e'] = $city[$pos[0]][$pos[1]+1]}
            if($pos[1] -eq 0 -or $visited -contains "$($pos[0]),$($pos[1]-1)") { $heat.remove('w') } else { $heat['w'] = $city[$pos[0]][$pos[1]-1] + 10}
        }
    }
    write-verbose "  N=$($heat['n']) S=$($heat['s']) E=$($heat['e']) W=$($heat['w'])"
    $lowest = ($heat.GetEnumerator() | sort-object Value)[0]
    $newdir = $lowest.Key
    if($newdir -ne $dir) { $count = 1 } else { $count++ }
    switch($newdir) {
        'n' { $pos[0]-- }
        'e' { $pos[1]++ }
        's' { $pos[0]++ }
        'w' { $pos[1]-- }
    }
    $dir = $newdir

    $visited += "$($pos[0]),$($pos[1])"

    $totalheat += $lowest.Value
    write-verbose "  $lowest"
}

$totalheat