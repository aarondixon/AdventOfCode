[cmdletbinding()]
param(
    $inputfile = ".\sample.txt",
    $targetsteps = 16
)

$text = Get-Content $inputfile
$maxX = $text[0].length - 1
$maxY = $text.count - 1
$grid = [char[,]]::new($maxX+1,$maxY+1)
for($r = 0; $r -le $maxY; $r++) {
    $line = $text[$r].ToCharArray()
    for($c = 0; $c -le $maxX; $c++) {
        $grid[$c,$r] = $line[$c]
        if($grid[$c,$r] -eq 'S') { $start = New-Object System.Management.Automation.Host.Coordinates($c,$r) }
    }
}

function FindValidSteps { #TOO SLOW :(
    param([System.Management.Automation.Host.Coordinates]$pos)

    [System.Management.Automation.Host.Coordinates[]]$result = @()
    foreach($mod in ((0,-1),(1,0),(0,1),(-1,0))) {
        $newx = $pos.X + $mod[0]
        $newy = $pos.Y + $mod[1]
        if($newy -le $maxY -and $newx -le $maxX) {
            if($grid[$newx,$newy] -ne "#") { $result += @{X=$newx;Y=$newy} }
        }
    }

    return $result
}

Write-Verbose "START $start"
[System.Management.Automation.Host.Coordinates[]]$positions = @()
$positions += $start
for($s = 1; $s -le $targetsteps; $s++) {
    write-verbose "STEP $s"
    [System.Management.Automation.Host.Coordinates[]]$newpos = @()
    foreach($pos in $positions) {
        $newpos += FindValidSteps $pos
    }
    $positions = $newpos

    for($y = 0; $y -le $maxY; $y++) {
        $line = ""
        for($x = 0; $x -le $maxX; $x++) {
            if($positions -contains [System.Management.Automation.Host.Coordinates]@{X=$x;Y=$y}) { $line += "O"} else { $line += $grid[$x,$y]}
        }
        write-Output $line
    }
    read-host
}

write-output $positions.count