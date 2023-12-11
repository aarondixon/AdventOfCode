[cmdletbinding()]
param(
    $text = (Get-Content "sample3.txt")
)

class Node {
    [string]$id
    $Next
    [bool]$isZ
    [bool]$isA

    Node($id,$left,$right) {
        $this.id = $id
        $this.Next = @{'L' = $left; 'R' = $right}
        $this.isZ = ($id[2] -eq 'Z')
        $this.isA = ($id[2] -eq 'A')
    }
}

function GCD($n, $m) {
  $a = ($n,$m | Measure-Object -Maximum).Maximum
  $b = ($n,$m | Measure-Object -Minimum).Minimum
  $r = 0
  while ($b -ne 0) {
    $r = $a % $b
    $a = $b
    $b = $r
  }

  return $a
}

function LCM($a,$b) {
    return (($a * $b) / (GCD $a $b))
}

$nodes = @{}
for($l = 0; $l -lt $text.count; $l++) {
    if($l -eq 0) {
        [char[]]$inst = $text[$l]
        continue
    }

    $line = $text[$l] -replace "\s+",""

    if($line -match '(.+)=\((.+),(.+)\)') {
        $id = $Matches[1]
        $left = $Matches[2]
        $right = $Matches[3]
        $nodes[$id] = [Node]::new($id,$left,$right)
    }

}

#$nodes

$startnode = $nodes[($nodes.Values | Where-Object {$_.isA -eq $true} | Select-Object -ExpandProperty id) ]
$allsteps = @()

#$startnode | ft
#read-host

foreach($n in $startnode) {
    $steps = 0
    $i = 0
    $node = $n    
    do {
        if($i -gt ($inst.Count - 1)) { $i = 0}
        #write-verbose $inst[$i]
        $node = $nodes[($node.Next.($inst[$i].ToString()))]
        $i++
        $steps++
    } while ($node.isZ -eq $false)
    $allsteps += $steps
    write-verbose $steps
    read-host
}

function GCD($a, $b) {
    while ($b -ne 0) {
        $temp = $b
        $b = $a % $b
        $a = $temp
    }
    return $a
}

function LCM($a, $b) {
    return [Math]::abs($a * $b) / (GCD $a $b)
}

$lcm = LCM $allsteps[0] $allsteps[1]

for($i = 2; $i -lt $allsteps.count; $i++) {
    $lcm = LCM $lcm $allsteps[$i]
}

Write-Output "Total Steps: $lcm"