[cmdletbinding()]
param(
    $text = (Get-Content "input.txt"),
    $digits = "0".."9",
    $emptychar = ".",
    $gearchar = "*"
)

function FindCompleteNumber($r,$c) {
    #find left bound
    $left = 0
    $right = $text[$r].length
    for($i = $c; $i -ge 0; $i--) {
        if($digits -notcontains $text[$r][$i].tostring()) { $left = $i+1; break }
    }

    #find right bound
    for($j = $c; $j -lt $text[$r].length; $j++) {
        if($digits -notcontains $text[$r][$j].tostring()) { $right = $j; break }
    }

    #return number between bounds
    write-verbose "  Num found: $($text[$r].substring($left, $right-$left))"
    return [int]$text[$r].substring($left, $right-$left)
}


function FindSurroundingNumbers($r,$c) {
    $nums = @()

    if($r -gt 0) {#check row above
        if($digits -contains $text[$r-1][$c].tostring()) { #a number is directly above, find bounds
            $nums += (FindCompleteNumber -r ($r-1) -c $c)
        } else { # a symbol or empty character is above, check upper diagonals for numbers
            if($c -gt 0) { #upper left diagonal 
                if($digits -contains $text[$r-1][$c-1].tostring()) {
                    $nums += (FindCompleteNumber -r ($r-1) -c ($c-1))
                }
            }

            if($c -lt $text[$r].length-1) { #upper right diagonal
                if($digits -contains $text[$r-1][$c+1].tostring()) {
                    $nums += (FindCompleteNumber -r ($r-1) -c ($c+1))
                }
            }
        }
    }

    if($c -gt 0) {#check left
        if($digits -contains $text[$r][$c-1].tostring()) {
            $nums += (FindCompleteNumber -r $r -c ($c-1))
        }
    }

    if($c -lt $text[$r].length-1) { #check right
        if($digits -contains $text[$r][$c+1].tostring()) {
            $nums += (FindCompleteNumber -r $r -c ($c+1))
        }
    }

    if($r -lt $text.count-1) {#check row below
        if($digits -contains $text[$r+1][$c].tostring()) { #a number is directly below, find bounds
            $nums += (FindCompleteNumber -r ($r+1) -c $c)
        } else { # a symbol or empty character is below, check lower diagonals for numbers
            if($c -gt 0) { #lower left diagonal 
                if($digits -contains $text[$r+1][$c-1].tostring()) {
                    $nums += (FindCompleteNumber -r ($r+1) -c ($c-1))
                }
            }

            if($c -lt $text[$r].length-1) { #lower right diagonal
                if($digits -contains $text[$r+1][$c+1].tostring()) {
                    $nums += (FindCompleteNumber -r ($r+1) -c ($c+1))
                }
            }
        }
    }

    return $nums
}

write-verbose "$($text.count) lines"
$sum = 0
for($l = 0; $l -lt $text.count; $l++) {
    $line = $text[$l]
    Write-Verbose "Line $($l+1)"
    for($i = 0; $i -lt $line.length; $i++) {
        if($line[$i].tostring() -eq $gearchar) {
            $numbers = FindSurroundingNumbers -r $l -c $i
            Write-Verbose "  Adjacent Numbers ($($numbers.count)): $($numbers -join "; ")"
            if($numbers.count -eq 2) { 
                $sum += $numbers[0] * $numbers[1]
                Write-Verbose $sum
            }
        }
    }
}

$sum