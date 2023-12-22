function Find-GCD($a, $b) {
    while ($b -ne 0) {
        $temp = $b
        $b = $a % $b
        $a = $temp
    }
    return $a
}

function LCM($a, $b) {
    return [Math]::abs($a * $b) / (Find-GCD $a $b)
}

function Find-LCM {
    param(
        [int[]]$numbers
    )

    $lcm = LCM $numbers[0] $numbers[1]

    for($i = 2; $i -lt $numbers.count; $i++) {
        $lcm = LCM $lcm $numbers[$i]
    }    

    return $lcm
}

Export-ModuleMember Find-LCM
Export-ModuleMember Find-GCD