[cmdletbinding()]
param(
    $instructions = (Get-Content ".\sample.txt"),
    $targetwire = "a"
)

function ReadInstructions() {
    $inst = @{}
    for($i = 0; $i -lt $instructions.length; $i++) {
        $line = $instructions[$i] -split "->"
        $wire = $line[1].trim()
        $inst[$wire] = $line[0].trim()
    }

    return $inst
}

function GetWireValue($wires, $wire) {
    write-verbose "$wire = $($wires[$wire])"
    $value = $wires[$wire] -as [uint16]
    if($null -eq $value) {
        $inst = $wires[$wire] -split "\s+"
        switch($inst.count) {
            1 {
                $left = $inst[0] -as [uint16]
                if($null -eq $left) {
                    $left = (GetWireValue $wires $inst[0])
                }
                $value = $left
                #return $left
            }

            2 { 
                $right = $inst[1] -as [uint16]
                if($null -eq $right) {
                    $right = (GetWireValue $wires $inst[1])
                }
                $value = (-bnot $right)
                #return (-bnot $right)
            }

            3 {
                $left = $inst[0] -as [uint16]
                if($null -eq $left) {
                    $left = (GetWireValue $wires $inst[0])
                }

                $right = $inst[2] -as [uint16]
                if($null -eq $right) {
                    $right = (GetWireValue $wires $inst[2])
                }

                #perform operation
                switch($inst[1]) {
                    "AND"    { $value = ($left -band $right)}
                    "OR"     { $value = ($left -bor $right)}
                    "LSHIFT" { $value = ($left -shl $right)}
                    "RSHIFT" { $value = ($left -shr $right)}
                }
            }
        }
        if($value -lt 0) { $value = [uint16]::MaxValue - [math]::abs($value) + 1 }
        $wires[$wire] = $value
        return $value

    } else {
        if($value -lt 0) { $value = [uint16]::MaxValue - [math]::abs($value) + 1 }
        return $value
    }
}

$wires = ReadInstructions

$a = GetWireValue $wires "a"

$wires = ReadInstructions

$wires["b"] = $a

GetWireValue $wires "a"