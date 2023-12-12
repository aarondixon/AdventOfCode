[cmdletbinding()]
param(
    $instructions = (Get-Content ".\sample.txt"),
    $targetwire = "a"
)

$wires = @{}

$todo = [system.collections.generic.list[object]](0..($instructions.length-1))
do {
    for($i = 0; $i -lt $todo.count; $i++) {
        $line = $instructions[$i] -split "->"
        $wire = $line[1].trim()

        $inst = $line[0].trim() -split "\s+"

        switch($inst.count) {
            1 {
                #assign value to wire
                $left = ($inst[0] -as [uint16])
                if($null -eq $left) { 
                    if($wires.ContainsKey($inst[0])) {
                        $left = [uint16]$wires[$inst[0]]
                    }
                }

                if($null -ne $left) {
                    $wires[$wire] = $left
                    write-verbose "$($inst[0]) -> $wire ($($wires[$wire]))"
                    $todo.remove($i)
                } else {
                    #$todo++
                    write-verbose "$($inst[0]) -> $wire (TODO)"
                }

                
            }

            2 { 
                #assign complement of value to wire
                $right = ($inst[1] -as [uint16])
                if($null -eq $right) {
                    if($wires.ContainsKey($inst[1])) {
                        $right = [uint16]$wires[$inst[1]]
                    } 
                }

                if($null -ne $right) {
                    $wires[$wire] = -bnot $wires[$inst[1]]
                    if($wires[$wire] -lt 0) { $wires[$wire] = [uint16]::MaxValue - [math]::abs($wires[$wire]) + 1 }
    
                    write-verbose "$($inst[0]) $($inst[1]) ($($wires[$wire])) -> $wire ($($wires[$wire]))"

                    $todo.Remove($i)
                } else {
                    #$todo += $i
                    write-verbose "NOT $($inst[1]) -> $wire (TODO)"
                }

            }

            3 {
                #perform operation
                $left = ($inst[0] -as [uint16])
                if($null -eq $left) { 
                    if($wires.ContainsKey($inst[0])) {
                        $left = [uint16]$wires[$inst[0]] 
                    }
                }

                $right = ($inst[2] -as [uint16])
                if($null -eq $right) { 
                    if($wires.ContainsKey($inst[2])) {
                        $right = [uint16]$wires[$inst[2]]
                    }
                }

                if($null -ne $left -and $null -ne $right) {

                    switch($inst[1]) {
                        "AND"    { $wires[$wire] = [uint16]($left -band $right) }
                        "OR"     { $wires[$wire] = [uint16]($left -bor $right) }
                        "LSHIFT" { $wires[$wire] = [uint16]($left -shl $right) }
                        "RSHIFT" { $wires[$wire] = [uint16]($left -shr $right) }
                    }
                    if($wires[$wire] -lt 0) { $wires[$wire] = [uint16]::MaxValue - [math]::abs($wires[$wire]) + 1 }
                    write-verbose "$($inst[0]) ($left) $($inst[1]) $($inst[2]) ($right) -> $wire ($($wires[$wire]))"
                    $todo.remove($i)
                } else {
                    #$todo++
                    write-verbose "$($inst[0]) $($inst[1]) $($inst[2]) -> $wire (TODO)"
                }
            }
        }

    }
} while ($todo.length -gt 0)

$wires

$wires["b"] = $wires[$targetwire]