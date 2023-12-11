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

function PrintStep($step) {
    return ("{0} ({1},{2})" -f $step.Pipe,$step.Coord[0],$step.Coord[1])
}
function IsPointInsidePolygon {
    param (
        [double]$pointX,
        [double]$pointY,
        [double[]]$polygonVerticesX,
        [double[]]$polygonVerticesY
    )

    $verticesCount = $polygonVerticesX.Length
    $isInside = $false
    $j = $verticesCount - 1

    for ($i = 0; $i -lt $verticesCount; $i++) {
        $xi = $polygonVerticesX[$i]
        $yi = $polygonVerticesY[$i]
        $xj = $polygonVerticesX[$j]
        $yj = $polygonVerticesY[$j]

        $intersect = (($yi -le $pointY -and $yj -gt $pointY) -or ($yj -le $pointY -and $yi -gt $pointY)) -and
                      ($pointX -lt ($xj - $xi) * ($pointY - $yi) / ($yj - $yi) + $xi)

        if ($intersect) {
            $isInside = -not $isInside
        }

        $j = $i
    }

    return $isInside
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
    #write-verbose (PrintCoord $test)
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
$path = @()
$path += @{Pipe="S";Coord = $start; Str = $start -join ","}

do {
    $p = [string]$field[$current[0]][$current[1]]
    $step = @{Pipe = $p; Coord = $current; Str = ($current -join ",")}
    #PrintStep $step
    $path += $step
    if(-not (CompCoords $prev (AddCoords $current $pipes[$p].before))) {
        $prev = $current
        $current = AddCoords $current $pipes[$p].before
    } else {
        $prev = $current
        $current = AddCoords $current $pipes[$p].after
    }
} while (-not (CompCoords $current $start))

Write-Output "Max Distance: $([math]::floor($path.count / 2))"

$simplepath = @()
$vertr = @()
$vertc = @()
foreach($step in $path) {
    if($step.Pipe -ne '|' -and $step.Pipe -ne '-') { 
        $simplepath += $step
        $vertr += $step.Coord[0]
        $vertc += $step.Coord[1]
    }
}

$blanks = @()
write-output $path.Str
for($r = 0; $r -lt $field.length; $r++) {
    for($c = 0; $c -lt $field[$r].length; $c++) {
        if($path.Str -notcontains (($r,$c) -join ",")) {
            $blanks += ,($r,$c)
        }
    }
}

$blanks.Count

$Interior = @()

foreach($b in $blanks) {
    #if( (InPoly $nverts $vertr $vertc $b[0] $b[1])) {
    $isInside = IsPointInsidePolygon $b[1] $b[0] $vertc $vertr
    write-verbose "$(PrintCoord $b) $isInside"
    if( $isInside ) {
        $Interior += ,($b[0],$b[1])
    }
}

$Interior.Count

