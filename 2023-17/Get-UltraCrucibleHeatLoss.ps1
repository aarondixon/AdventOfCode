[cmdletbinding()]
param(
    $inputfile = ".\sample.txt",
    $max = 10,
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

    #$dist = @{}
    #$prev = @{}
    #$Q = [system.collections.generic.list[string]]::new()
    $Q = [System.Collections.Generic.PriorityQueue[string,int]]::new()
    $Q.Enqueue("0,0,0",0)
    $Q.Enqueue("0,0,1",0)

    <#foreach($key in $grid.Keys) {
        $dist["$key,0"] = 999
        $dist["$key,1"] = 999
        $prev["$key,0"] = -1
        $prev["$key,1"] = -1
        $Q.Enqueue("$key,0")
        $Q.Add("$key,1")
    }#

    $dist["0,0,0"] = 0
    $dist["0,0,1"] = 0#>


    $seen = @()

    while($Q.Count -gt 0) {
        #$u = GetMinDistance $Q $dist
        [string]$u = ""
        [int]$cost = 0
        $Q.TryDequeue([ref]$u,[ref]$cost) | Out-null
        write-verbose "$u"




        $pos = [int16]($u -split ",")[0],[int16]($u -split ",")[1]
        $dir = [int16]($u -split ",")[2]

        if("$($pos[0]),$($pos[1])" -eq $target) { break }
        if($seen -contains $u) { continue }

        $seen += $u

        $originalcost = $cost
        foreach($s in (-1,1)) {
            $newr = $pos[0]
            $newc = $pos[1]
            $cost = $originalcost
            for($d = 1; $d -le 3; $d++) {
                if($dir -eq 1) {
                    $newc = $pos[1] + $d * $s
                } else {
                    $newr = $pos[0] + $d * $s
                }

                if($newr -lt 0 -or $newr -gt $maxr -or $newc -lt 0 -or $newc -gt $maxc) { break }

                $cost += $grid["$newr,$newc"]
            }
            for($d = 4; $d -le $max; $d++) {
                if($dir -eq 1) {
                    $newc = $pos[1] + $d * $s
                } else {
                    $newr = $pos[0] + $d * $s
                }

                if($newr -lt 0 -or $newr -gt $maxr -or $newc -lt 0 -or $newc -gt $maxc) { break }

                $cost += $grid["$newr,$newc"]
                $newkey = "$newr,$newc,$(1-$dir)"
                if($seen -contains $newkey ) { continue }
                write-verbose "  $newkey = $cost ($($Q.count))"
                if($d -ge 1) { $Q.Enqueue($newkey,$cost)}
            }
        }
        
        <#foreach($v in $neighbors.GetEnumerator()) {
            if($Q.Contains($v.Key)) { 
                #$alt = $dist[$u] + $grid[$v.Value]
                $alt = $v.Value
                write-verbose "  $v ($alt)"
                if($alt -lt $dist[$v.Key]) {
                    $dist[$v.Key] = $alt
                    $prev[$v.Key] = $u
                }
            }
        }#>
    }

    #return @{distance = $dist; path = $prev}
    return $cost
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

$result