using namespace System.Collections.Generic

[cmdletbinding()]
param(
    $inputfile = ".\sample.txt"
)

class Path {
    [int[]]$start
    [int[]]$end
    [int]$length

    Path($start, $end, $length) {
        $this.start = $start
        $this.end = $end
        $this.length = $length
    }
}


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

function walk([int[]]$curr,[hashset[string]]$path) {
    #write-verbose "  $curr : $($path.count) ($($forest[$curr[0]][$curr[1]])))"
    $path.add("$curr") | out-null

    if($curr[0] -eq $end[0] -and $curr[1] -eq $end[1]) {
        return ($curr,$path.count)
    }

    $next = @()
    foreach($mod in $modcoords) {
        $r = $curr[0] + $mod[0]
        $c = $curr[1] + $mod[1]
     
        if($r -ge 0 -and $c -ge 0 -and $forest[$r][$c] -ne '#' -and -not $path.contains("$($r,$c)")) {
            #write-verbose "    $r,$c"
            $next += ,($r,$c)
        }
    }

    if($next.count -gt 1) {
        return ($curr,$path.count)
    } elseif($next.count -eq 1) {
        return (walk $next[0] $path)
    }

    return $null,0
}

$paths = @{}#[hashset[Path]]::new()

$nodes = [queue[object]]::new()
$nodes.enqueue($start)

while($nodes.count -gt 0) {
    $node = $nodes.Dequeue()
    
    write-verbose "NODE $node"

    foreach($mod in $modcoords) {
        $r = $node[0] + $mod[0]
        $c = $node[1] + $mod[1]

        if($r -ge 0 -and $c -ge 0 -and $r -lt $forest.count -and $c -lt $forest[$forest.count-1].count) {
            if($forest[$r][$c] -ne '#' ) {
                write-verbose "  -> $r $c"
                $path = [hashset[string]]::new()
                $path.add("$($node[0],$node[1])") | out-null
                $next,$length = walk ($r,$c) $path
                write-verbose "$next"
                write-verbose "$length"
                
                if($null -ne $next -and -not $paths.containskey("$node - $next") -and -not $paths.containskey("$next - $node")) {
                    $paths["$node - $next"] = [Path]::new($node,$next,$length)
                    if("$next" -ne "$end") { 
                        $nodes.Enqueue($next)
                    } else {
                        write-verbose "END"
                    }
                }
            }
        }
    }
}

$global:longestpath = 0

function jump ($curr,$length,$path) {
    $path += "$curr"
    write-verbose ("$($path.count) {0}$curr : $length" -f (" "*$path.count))
    if("$curr" -eq "$end") {
        if($length -gt $global:longestpath) { write-host "FOUND END : $length"; $global:longestpath = $length }
        return $length
    }

    $longest = 0
    foreach($next in ($paths.Values | Where-Object { "$($_.start)" -eq "$curr" -or "$($_.end)" -eq "$curr"} )) {
        if("$($next.end)" -ne "$curr") {
            $nextcoord = $next.end
        }else {
            $nextcoord = $next.start
        }

        if($path -notcontains "$nextcoord") {
            write-verbose ("$($path.count) {0}$curr -> $($nextcoord) : $($next.length)" -f (" "*$path.count))
            $count = jump $nextcoord ($length + $next.length - 1) (@() + $path)
            if($count -gt $longest) { $longest = $count}
        }
    }

    return $longest

}

$paths

#$nodes = [queue[object]]::new()
#$nodes.enqueue($start)

#while($nodes.count -gt 0) {
#    $node = $nodes.dequeue()
#
    #write-verbose "NODE $node"
#}

jump $start 0 @()