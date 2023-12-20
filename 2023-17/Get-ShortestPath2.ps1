[cmdletbinding()]
param(
    $inputfile = ".\sample.txt",
    $max = 3,
    $target
)

function GetDirection {
    param(
        $curr,
        $next
    )

    #write-verbose "GetDirection: $curr -> $next"

    if($curr -eq "" -or $next -eq "") { return "x"}

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

    while($Q.Count -gt 0) {
        $u = GetMinDistance $Q $dist
        write-verbose "$u"
        #if($u -eq $target) { break }
        $Q.Remove($u)
        #$newdir = GetDirection $prevnode $u
        #write-verbose "$prevnode -> $newdir -> $u ($dir)"
        #$prevnode = $u


        $pos = [int16]($u -split ",")[0],[int16]($u -split ",")[1]
        $neighbors = @{}

        <#
        $p = $u
        $dir = ""
        $path = "$u"
        for($i = 0; $i -lt 3; $i++) {
            if($p -and $prev[$p] -ne -1) {
                $path = "{0} ({1}) -> {2}" -f $prev[$p],$dist[$p],$path
                $dir = (GetDirection $prev[$p] $p) + $dir
                $p = $prev[$p]
            }            
        }
        write-verbose "  $path $dir"

        #>

        if($pos[1] -lt $maxc -and $dir -ne "eee") { $neighbors["e"] = "$($pos[0]),$($pos[1]+1)" }
        if($pos[0] -lt $maxr -and $dir -ne "sss") { $neighbors["s"] = "$($pos[0]+1),$($pos[1])" }
        if($pos[1] -gt 0 -and $dir -ne "www") { $neighbors["w"] = "$($pos[0]),$($pos[1]-1)" }
        if($pos[0] -gt 0 -and $dir -ne "nnn") { $neighbors["n"] = "$($pos[0]-1),$($pos[1])" }        

        foreach($v in $neighbors.GetEnumerator()) {
            if($Q.Contains($v.Value)) { 
                $alt = $dist[$u] + $grid[$v.Value]
                write-verbose "  $v ($alt)"
                if($alt -lt $dist[$v.Value]) {
                    $dist[$v.Value] = $alt
                    $prev[$v.Value] = $u
                }
            }
        }
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
if(-not $target) { $target = "$($r-1),$($c-1)" }
write-verbose "$start -> $target"
$result = Dijkstra $start $city $target ($r-1) ($c-1)
$u = $target
$path = "$u"
while($u) {
    if($result.path[$u] -ne -1) {
        $path = "{0} -> {1}" -f $result.path[$u],$path
    }
    $u = $result.path[$u]
}

$steps = $path -split "->"
$grid = @()
for($r = 0; $r -lt $text.count; $r++) {
    $grid += ,$text[$r].ToCharArray()
}

$prevcoord = @()
$char = "X"
foreach($step in ($path -split "->")) {
    $coord = $step.trim() -split ","
    if($prevcoord.count -gt 0) {
        switch(GetDirection ($prevcoord -join ",") $step.trim()) {
            "e" { $char = ">"}
            "s" { $char = "v"}
            "w" { $char = "<"}
            "n" { $char = "^"}
        }
    } else {
        $char = "@"
    }
    $prevcoord = $coord
    $grid[$coord.trim()[0]][$coord[1]] = $char
    
}

foreach($r in $grid) {
    write-output ($r -join " ")
}

$path
$result.distance[$target]