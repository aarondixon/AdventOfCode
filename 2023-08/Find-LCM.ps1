[cmdletbinding()]
param(
    [int[]]$numbers
)

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

$lcm = LCM $numbers[0] $numbers[1]

for($i = 2; $i -lt $numbers.count; $i++) {
    $lcm = LCM $lcm $numbers[$i]
}

return $lcm