[cmdletbinding()]
param(
    $text = (Get-Content "sample2.txt")
)

$nodes = @{}
for($l = 0; $l -lt $text.count; $l++) {
    if($l -eq 0) {
        [char[]]$inst = $text[$l]
        continue
    }

    $line = $text[$l] -replace "\s+",""

    if($line -match '(\D+)=\((\D+),(\D+)\)') {
        $nodes[$Matches[1]] = @{'L' = $Matches[2]; 'R' = $Matches[3]}
    }

}

$nodes

$node = 'AAA'
$steps = 0
$i = 0
do {
    if($i -gt ($inst.Count - 1)) { $i = 0}
    Write-Verbose "$node ($($inst[$i])) -> $($nodes[$node].($inst[$i].tostring()))"
    $node = $nodes[$node].($inst[$i].ToString())
    $i++
    $steps++
} while ($node -ne 'ZZZ')

$steps