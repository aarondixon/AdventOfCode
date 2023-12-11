[cmdletbinding()]
param(
    $text = (Get-Content "input.txt")
)


#read in all cards
#$cards = @{}
$cards = @(1) * ($text.count + 1)
$cards[0] = 0

foreach($l in $text) {
    $cardnum = [int](($l -split ":")[0] -replace "Card","").trim()
    $winners = (($l -split ":")[1] -split "\|")[0].trim() -split "\s+"
    $numbers = (($l -split ":")[1] -split "\|")[1].trim() -split "\s+"

    $nummatches = 0
    foreach($n in $numbers) {
        if($winners -contains $n) {
            $nummatches++
        }
    }

    write-verbose "Card $cardnum"
    write-verbose "  Winners: $($winners -join ",")"
    write-verbose "  Numbers: $($numbers -join ",")"
    write-verbose "  Matches: $nummatches"

    for($i = ($cardnum + 1); $i -le ($cardnum + $nummatches); $i++) {
        $cards[$i] += $cards[$cardnum]
    }
}

$cards | measure-object -sum | select -ExpandProperty sum