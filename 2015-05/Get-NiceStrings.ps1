[cmdletbinding()]
param(
    $text = (Get-Content ".\sample2.txt")
)

$badstrings = @("ab","cd","pq","xy")

$vowels = @("a","e","i","o","u")

function IsNice($str) {
    foreach($bs in $badstrings) {
        if($str -match $bs) {
            write-verbose "  bad string $bs found"
            return $false
        }
    }    

    if(-not ($str -match "(.)\1")) { write-verbose "  no double letters"; return $false }

    $vcount = (Select-String -AllMatches -Input $str -Pattern "[aeiou]").Matches.Count
    if($vcount -lt 3) {
        write-verbose "  less than 3 vowels"
        return $false
    }

    return $true
}

function IsNice2($str) {

    $cond1 = $false
    for($i = 0; $i -lt $str.length-2; $i++) {
        $rest = $str.substring($i+2)
        $pair = $str.substring($i,2)
        if($rest -match $pair) {
            write-verbose "  $pair repeats"
            $cond1 = $true
            break
        }
    }

    $cond2 = $false
    for($i = 0; $i -lt $str.length-2; $i++){
        if($str[$i] -eq $str[$i+2]) {
            write-verbose "  $($str[$i]) appears two characters later"
            $cond2 = $true
            break
        }
    }

    return ($cond1 -and $cond2)
}

$nice1 = 0
$nice2 = 0
foreach($l in $text) {
    write-verbose $l
    #if(IsNice $l) { $nice1++ }
    if(IsNice2 $l) { $nice2++ }
}

$nice1
$nice2