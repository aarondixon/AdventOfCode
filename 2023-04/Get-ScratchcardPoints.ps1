[cmdletbinding()]
param(
    $text = (Get-Content "input.txt")
)

$sum = 0
foreach($l in $text) {
    $cardnum = [int](($l -split ":")[0] -replace "Card","").trim()
    $winners = (($l -split ":")[1] -split "\|")[0].trim() -split "\s+"
    $numbers = (($l -split ":")[1] -split "\|")[1].trim() -split "\s+"

    write-verbose "Card $cardnum"
    write-verbose "  Winners: $($winners -join ",")"
    write-verbose "  Numbers: $($numbers -join ",")"

    $matches = 0
    foreach($n in $numbers) {
        if($winners -contains $n) {
            $matches++
        }
    }

    if($matches -gt 0) { 
        $points = [math]::pow(2,($matches - 1))
    } else {
        $points = 0
    }
    write-verbose "  Points: $points ($matches matches)"

    $sum += $points

}

$sum
