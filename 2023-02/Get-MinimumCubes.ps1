[cmdletbinding()]
param(
    $inputfile = "input.txt"
)

$text = get-content $inputfile

$games = @()
$sum = 0
foreach($l in $text) {
    $game = @{}
    $game.rounds = @()

    $game.id = [int](($l -split ":")[0] -replace "Game ","")
    Write-Verbose "Game $($game.id)"

    $minred = 0
    $mingreen = 0
    $minblue = 0

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
        if($red -gt $minred) { $minred = $red}
        if($green -gt $mingreen) { $mingreen = $green}
        if($blue -gt $minblue) { $minblue = $blue}

        $round = @{red = $red; green = $green; blue = $blue}
        Write-Verbose ("  Red: {0}, Green: {1}, Blue: {2}" -f $round.red, $round.green, $round.blue)
        $game.rounds += $round
    }

    $game.minred = $minred
    $game.mingreen = $mingreen
    $game.minblue = $minblue
    $game.power = $minred * $mingreen * $minblue

    Write-Verbose " Min Red: $minred; Min Green: $mingreen; Min Blue: $minblue; POWER: $($game.power)"

    $games += $game
    $sum += $game.power
}

$sum

