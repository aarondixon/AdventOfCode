[cmdletbinding()]
param(
    $Start = "1",
    $Rounds = 5
)

function SayString {
    param(
        $str
    )

    write-verbose $str

    $result = [System.Text.StringBuilder]::new()
    foreach($m in (select-string -InputObject $str -Pattern "(\w)\1*" -AllMatches).Matches) {
        [void]$result.append($m.Length)
        [void]$result.append($m.Value[0])
    }   

    return $result.tostring()
}

$str = $Start
for($round = 0; $round -lt $Rounds; $round++) {
    write-progress -Activity "Working" -Status "Round $round" -PercentComplete ($round/$Rounds * 100) -id 1
    $str = SayString $str
}

$str.length