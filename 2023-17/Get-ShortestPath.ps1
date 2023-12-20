[cmdletbinding()]
param(
    $inputfile = ".\sample.txt",
    $max = 3,
    $target
)

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
    $dist["0,0,0"] = 0
    $dist["0,0,1"] = 0
    $seen = @()

    while($dist.count -gt 0) {
        $u = ($dist.GetEnumerator() | Sort-Object Value).Key | Select-Object -First 1
        write-verbose "$u"
        $origcost = $dist[$u]
        $seen += $u
        $dist.Remove($u)

        $pos = [int16]($u -split ",")[0],[int16]($u -split ",")[1]

        if("$($pos[0]),$($pos[1])" -eq $target) { return $origcost }

        $dir = [int16]($u -split ",")[2]

        foreach($s in (-1,1)) {
            $cost = $origcost
            $newr = $pos[0]
            $newc = $pos[1]
            for($d = 1; $d -le $max; $d++) {
                if($dir -eq 1) {
                    $newc = $pos[1] + $d * $s
                } else {
                    $newr = $pos[0] + $d * $s
                }

                if($newr -lt 0 -or $newr -gt $maxr -or $newc -lt 0 -or $newc -gt $maxc) { break }

                $cost += $grid["$newr,$newc"]

                $newkey = "$newr,$newc,$(1-$dir)"

                if($seen -contains $newkey) { continue }
                
                $dist[$newkey] = $cost

                write-verbose "  $newr,$newc ($(1-$dir)) = $cost [$newkey]"
            }
        }
    }

    return 0
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