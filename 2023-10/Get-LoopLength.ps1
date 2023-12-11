[cmdletbinding()]
param(
    [string]$inputfile,
    [char]$StartChar = 'S'
)

function AddCoords($coord1,$coord2) {
    return ($coord1[0] + $coord2[0]),($coord1[1] + $coord2[1])
}

function CompCoords($coord1,$coord2) {
    if($coord1[0] -eq $coord2[0] -and $coord1[1] -eq $coord2[1]) {
        return $true
    }

    return $false
}

function PrintCoord($coord) {
    return "($($coord[0]),$($coord[1]))"
}

$pipes = @{}
$pipes['|'] = @{before=-1,0; after=1,0}
$pipes['-'] = @{before=0,-1; after=0,1}
$pipes['L'] = @{before=-1,0; after=0,1}
$pipes['J'] = @{before=-1,0; after=0,-1}
$pipes['7'] = @{before=0,-1; after=1,0}
$pipes['F'] = @{before=0,1; after=1,0}

$search = @((0,-1),(1,0),(0,1),(-1,0))

$text = Get-Content $inputfile
$field = @()
$start = @()
for($r = 0; $r -lt $text.length; $r++) {
    $line = $text[$r].ToCharArray()
    $field += ,$line
    if($line -contains $StartChar) {
        $start = $r,$line.IndexOf($StartChar)
    }
}

write-verbose "Start: $(PrintCoord $start)"
$current = @()
#find first pipe
foreach($s in $search) {
    $test = AddCoords $start $s
    write-verbose (PrintCoord $test)
    if($test[0] -ge 0 -and $test[0] -lt $field.length -and $test[1] -ge 0 -and $test[1] -lt $field[0].length) {
        $p = [string]$field[$test[0]][$test[1]]
        if($pipes.containskey($p)) {
            if((CompCoords $start (AddCoords $test $pipes[$p].before)) -or (CompCoords $start (AddCoords $test $pipes[$p].after))) {
                $current = $test
                
                break
            }
        }
    }
}

$prev = $start
[string[]]$path = @()
$path += ("S {0}" -f (PrintCoord $start))

write-verbose ($path -join "; ")
do {
    $p = [string]$field[$current[0]][$current[1]]
    $step = ("{0} {1}" -f $p,(PrintCoord $current))
    write-verbose $step
    $path += $step
    if(-not (CompCoords $prev (AddCoords $current $pipes[$p].before))) {
        $prev = $current
        $current = AddCoords $current $pipes[$p].before
    } else {
        $prev = $current
        $current = AddCoords $current $pipes[$p].after
    }
} while (-not (CompCoords $current $start))

[math]::floor($path.count / 2)