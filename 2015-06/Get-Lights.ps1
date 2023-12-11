[cmdletbinding()]
param(
    $instructions = (Get-Content ".\sample.txt"),
    [string]$part2
)

$grid = @()
for($r = 0; $r -lt 1000; $r++) {
    $grid += ,(@(0) * 1000)
}

foreach($inst in $instructions) {
    write-verbose $inst
    if($inst.StartsWith("turn on")) {
        $action = "on" + $part2
        $inst = ($inst -replace "turn on","").trim()
    } elseif ($inst.StartsWith("toggle")) {
        $action = "toggle" + $part2
        $inst = ($inst -replace "toggle","").trim()
    } elseif ($inst.StartsWith("turn off")) {
        $action = "off" + $part2
        $inst = ($inst -replace "turn off","").trim()
    }

    write-verbose "  $action"

    $range = $inst -split " through "
    $start = [int[]]($range[0] -split ",")
    $end = [int[]]($range[1] -split ",")

    for($r = $start[0]; $r -le $end[0]; $r++) {
        for($c = $start[1]; $c -le $end[1]; $c++) {
            switch($action) {
                "on" { $grid[$r][$c] = 1 }
                "off" { $grid[$r][$c] = 0 }
                "toggle" { $grid[$r][$c] = -not $grid[$r][$c]}
                ("on"+$part2) { $grid[$r][$c] += 1 }
                ("off"+$part2) { $grid[$r][$c] -= 1; if($grid[$r][$c] -lt 0) {$grid[$r][$c] = 0} }
                ("toggle"+$part2) { $grid[$r][$c] += 2}                
            }      
        }
    }
}

($grid | foreach-object {$_} ) | measure-object -sum | select-object sum