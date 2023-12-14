[cmdletbinding()]
param(
    $pass = "abcdefgh"
)

function ToAlpha([int64]$value) {
    #write-verbose "  $value"
    $result = ""
    do {
        $result = [char](97 + ($value % 26)) + $result
        $value = [math]::floor($value / 26)
    } while ($value -ge 1)
    $result = "a" * (8-$result.length) + $result
    #write-verbose "  -> $result"
    return $result
}

function FromAlpha([string]$value) {
    #write-verbose "  $value"
    [int64]$result = 0
    for($i = $value.length - 1; $i -ge 0; $i--) {
        $a = $value[$value.length - $i - 1]
        $v = [int]([char]$a) - 97
        #write-verbose "    $a = $v ($($v * [math]::pow(26,$i)))"
        $result += $v * [math]::pow(26,$i)
    }
    #write-verbose "  -> $result"
    return $result
}


function IsValid([string]$pass) {
    write-verbose "$pass"
    if($pass -notmatch "(?:abc|bcd|cde|def|efg|fgh|ghi|hij|ijk|jkl|klm|lmn|mno|nop|opq|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz)") {
        write-verbose "  missing consecutive"
        return $false
    }

    if($pass -match "[ilo]") { #this case can be sped up greatly by finding the first occurence of one of these letters, and incrementing the password by 1*26^[length - 1 - index]
        write-verbose "  contains i, l, or o"
        return $false
    }

    if(($pass | Select-STring -pattern "(.)\1" -AllMatches).Matches.Count -lt 2) {
        write-verbose "  missing pairs"
        return $false
    }

    return $true
}

do {
    $pass = ToAlpha ((FromAlpha $pass) + 1)
} while (-not (IsValid $pass))

write-output $pass

#ToAlpha 58137454778
<#

     a           b          c         d        e        f        g        h
0*26^7 +    1*26^6 +   2*26^5 +  3*26^4 + 4*26^3 + 5*26^2 + 6*26^1 + 7*26^0
     0 + 308915776 + 23762752 + 1370928 +  70304 +   3380 +    156 +      7
#>