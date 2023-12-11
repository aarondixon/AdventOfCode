[cmdletbinding()]
param(
    $text = (Get-Content ".\input.txt"),
    $floor = -1
)

$instructions = $text -replace "`n",""

$floor = 0
for($i = 0; $i -lt $instructions.length; $i++) {
    if($instructions[$i] -eq "(") { $floor++ } else { $floor-- }
    if($floor -eq -1) { break }
}

$i+1