[cmdletbinding()]
param(
    $Start = "1",
    $Rounds = 5
)

$str = $Start
for($round = 0; $round -lt $Rounds; $round++) {
    write-progress -Activity "Working" -Status "Round $round" -PercentComplete ($round / $Rounds * 100) -id 1
    Write-Verbose $str
    if($str.length -eq 1) {
        $str = "1$($str[0])"
        continue
    }

    $newstr = ""
    $count = 1
    for($i = 1; $i -lt $str.length; $i++) {
        Write-Progress -ParentId 1 -PercentComplete ($i/$str.length * 100) -Activity "Working"
        if($str[$i] -eq $str[$i-1]) { $count++ }

        if($str[$i] -ne $str[$i-1]) {
            $newstr += "$count$($str[$i-1])"
            $count = 1
        }

        if($i + 1 -eq $str.length) {
            $newstr += "$count$($str[$i])"
        }
    }

    $str = $newstr
}

$str.length