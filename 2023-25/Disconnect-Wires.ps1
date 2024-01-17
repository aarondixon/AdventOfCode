[cmdletbinding()]
param(
    $inputfile = "sample.txt"
)

$wires = @{}

foreach($line in (Get-content $inputfile)) {
    $wire = ($line -split ":")[0].trim()
    $connections = ($line -split ":")[1].trim() -split " "

    if(-not $wires.containskey($wire)) { $wires[$wire] = @() }
    foreach($w in $connections) {
        $wires[$wire] += $w

        if(-not $wires.containskey($w)) { $wires[$w] = @()}
        $wires[$w] += $wire
    }
}

$wires

