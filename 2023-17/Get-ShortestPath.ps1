[cmdletbinding()]
param(
    $inputfile = ".\sample.txt",
    $max = 3
)

function GetDirection {
    param(
        $curr,
        $next
    )

    if($curr -eq "") { return "x"}

    $curr_r = [int16]::parse(($curr -split ",")[0])
    $curr_c = [int16]::parse(($curr -split ",")[1])
    $next_r = [int16]::parse(($next -split ",")[0])
    $next_c = [int16]::parse(($next -split ",")[1])

    if($curr_r -lt $next_r -and $curr_c -eq $next_c) { return "s"}
    if($curr_r -gt $next_r -and $curr_c -eq $next_c) { return "n"}
    if($curr_r -eq $next_r -and $curr_c -lt $next_c) { return "e"}
    if($curr_r -eq $next_r -and $curr_c -gt $next_c) { return "w"}

    return "x"
}

function GetMinDistance {
    param(
        $Q,
        $dist
    )
    
    foreach($key in ($dist.GetEnumerator() | Sort-Object Value).Key) {
        if($Q -contains $key) { return $key }
    }
}
function Dijkstra {
    param(
        $source,
        $grid,
        $target,
        $maxr,
        $maxc
    )

    $dist = @{}
    $prev = @{}
    $Q = [system.collections.generic.list[string]]::new()
    foreach($key in $grid.Keys) {
        $dist[$key] = 999
        $prev[$key] = -1
        $Q.Add($key.tostring())
    }

    #write-verbose $dist.Keys
    #write-verbose $Q.count

    $dist[$source] = 0
    $prevnode = ""
    $dir = ""
    while($Q.Count -gt 0) {
        $u = GetMinDistance $Q $dist $prevnode $dir
        if($u -eq $target) { break }
        $Q.Remove($u)
        #$newdir = GetDirection $prevnode $u
        #write-verbose "$prevnode -> $newdir -> $u ($dir)"

        #$prevnode = $u


        $pos = [int16]($u -split ",")[0],[int16]($u -split ",")[1]
        $neighbors = @{}

        <#
        if($pos[1] -lt $maxc -and $dir -ne "eee") { $neighbors["e"] = "$($pos[0]),$($pos[1]+1)" }
        if($pos[0] -lt $maxr -and $dir -ne "sss") { $neighbors["s"] = "$($pos[0]+1),$($pos[1])" }
        if($pos[1] -gt 0 -and $dir -ne "www") { $neighbors["w"] = "$($pos[0]),$($pos[1]-1)" }
        if($pos[0] -gt 0 -and $dir -ne "nnn") { $neighbors["n"] = "$($pos[0]-1),$($pos[1])" }
        #>

        if($pos[1] -lt $maxc) { $neighbors["e"] = "$($pos[0]),$($pos[1]+1)" }
        if($pos[0] -lt $maxr) { $neighbors["s"] = "$($pos[0]+1),$($pos[1])" }
        if($pos[1] -gt 0) { $neighbors["w"] = "$($pos[0]),$($pos[1]-1)" }
        if($pos[0] -gt 0) { $neighbors["n"] = "$($pos[0]-1),$($pos[1])" }

        foreach($v in $neighbors.GetEnumerator()) {
            if($Q.Contains($v.Value)) { 
                $newdir = $dir
                if(-not $newdir.endswith($v.Key)) { $newdir = $v.Key } else { $newdir += $v.Key }
                $alt = $dist[$u] + $grid[$v.Value]
                write-verbose "  $v ($alt) $newdir"
                if($alt -lt $dist[$v.Value] -and $newdir.length -lt 3) {
                    $dist[$v.Value] = $alt
                    $prev[$v.Value] = $u
                    $prevnode = $u
                    $dir = $newdir
                }
            }
        }
        write-verbose $prevnode
        #if(-not $dir.EndsWith($newdir)) { $dir = $newdir } else { $dir += $newdir }
    }
    return @{distance = $dist; path = $prev}
}

$city = @{}
$text = Get-Content $inputfile
for($r = 0; $r -lt $text.count; $r++) {
    for($c = 0; $c -lt $text[$r].length; $c++) {
        $city["$($r),$($c)"] = [int16]::parse($text[$r][$c])
    }
}

$start = "0,0"
$target = "$($r-1),$($c-1)"
write-verbose "$start -> $target"
$result = Dijkstra $start $city $target ($r-1) ($c-1)
$u = $target
$path = $u
while($u) {
    $path = $result.path[$u] + " -> $path"
    $u = $result.path[$u]
}
$path
$result.distance[$target]