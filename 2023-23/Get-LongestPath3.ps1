using namespace System.Collections.Generic

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
#$end = ($lines,($forest[$lines] -join "").IndexOf("."))
$end = (137,133)
#$end = (19,19)

$modcoords = @((-1,0),(0,-1),(1,0),(0,1))

$intersections = new-object HashSet[string]
$neighbors = @{}
$graph = @{}

$intersections.add("$start") | Out-null
$intersections.add("$end") | Out-Null

$script:paths = 0
$script:longest = 0
function Get-IntersectionDistance($pos,$distance,[string[]]$seen) {
    if($intersections.contains($pos)) {
        return $pos,$distance
    }

    $node = ($neighbors["$pos"] | Where-Object { $seen -notcontains $_ } | Select-Object -First 1)
    write-verbose "  $node"
    if($seen -notcontains $pos) { $seen += $pos }
    return (Get-IntersectionDistance $node ($distance + 1) $seen)
}

function BFS($node,$steps,[string[]]$seen) {
    write-verbose "$node = $end $($node -eq $end)"
    if($node -eq $end -or $null -eq $node) { 
        $script:paths++
        write-progress -Activity "Finding paths" -Status "$($script:paths) found"
        if($steps -gt $script:longest) { write-host $steps; $script:longest = $steps }
        return $steps
    }

    $result = @()
    foreach($n in $graph[$node]) {
        write-verbose "  $n"
        if($seen -contains $n[0]) { continue }

        $result += BFS $n[0] ($steps + $n[1]) ($seen + $node)
    }

    return $result
}


for($r = 0; $r -lt $forest.count; $r++) {
    for($c = 0; $c -lt $forest[$r].count; $c++) {
        #write-verbose "$r $c = $($forest[$r][$c])"
        if($forest[$r][$c] -eq '#') { continue }

        $exits = 0

        foreach($mod in $modcoords) {
            $newr = $r + $mod[0]
            $newc = $c + $mod[1]

            if($newr -lt 0 -or $newc -lt 0 -or $newr -ge $forest.count -or $newc -ge $forest[$r].count) { continue }

            if($forest[$newr][$newc] -eq '#') { continue }

            $exits++
            #write-verbose "  Neighbor $newr $newc"
            if($null -eq $neighbors["$r $c"]) { $neighbors["$r $c"] = new-object HashSet[string] }
            $neighbors["$r $c"].add("$newr $newc") | Out-null
        }

        if($exits -ge 3) { $intersections.add("$r $c") | Out-null; }
    }
}


foreach($i in $intersections) {
    write-verbose "INTERSECTION $i"
    foreach($n in $neighbors[$i]) {
        write-verbose "  NEIGHBOR $n"

        $target,$length = Get-IntersectionDistance $n 1 @($i)
        if($null -eq $graph[$i]) { $graph[$i] = new-object HashSet[object[]] }
        $graph[$i].add(($target,$length)) | Out-null
    }
}

$result = BFS "$start" 0 @("$start")
write-output ($result | Measure-Object -Maximum | Select-Object -Expandproperty Maximum)