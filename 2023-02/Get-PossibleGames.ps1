[cmdletbinding()]
param(
    $inputfile = "input.txt",
    $maxred = 12,
    $maxgreen = 13,
    $maxblue = 14
)

function RoundIsPossible {
    param($r,$g,$b)

    return (($r -le $maxred) -and ($g -le  $maxgreen) -and ($b -le $maxblue))
}

$text = get-content $inputfile

$games = @()
$sum = 0
foreach($l in $text) {
    $game = @{}
    $game.rounds = @()

    $game.id = [int](($l -split ":")[0] -replace "Game ","")
    Write-Verbose "Game $($game.id)"

    $results = ($l -split ":")[1]
    foreach($roundresult in ($results -split ";")) {
        $cubes = $roundresult -split ","
        $red = 0
        $green = 0
        $blue = 0
        foreach($color in $cubes) {
            if($color.tolower() -like "*red") {
                $red = [int]($color.tolower() -replace " red","")
            }
            if($color.tolower() -like "*green") {
                $green = [int]($color.tolower() -replace " green","")
            }            
            if($color.tolower() -like "*blue") {
                $blue = [int]($color.tolower() -replace " blue","")
            }
        }
        $round = @{red = $red; green = $green; blue = $blue; possible = (RoundIsPossible -r $red -g $green -b $blue)}
        Write-Verbose ("  Red: {0}, Green: {1}, Blue: {2}{3}" -f $round.red, $round.green, $round.blue, ($round.possible ? " [POSSIBLE]" : ""))
        $game.rounds += $round
    }


    #Write-Verbose "  Possible Rounds: $(($game.rounds | where-object {$_.possible -eq $true}).count); total rounds: $($game.rounds.count)"
    if((($game.rounds | where-object {$_.possible}) | measure-object).count -eq $game.rounds.count) {
        $game.possible = $true
    } else {
        $game.possible = $false
    }

    $games += $game
    if($game.possible) { $sum += $game.id; write-verbose "  * POSSIBLE *"}
}

$sum

