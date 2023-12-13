[cmdletbinding()]
param(
    $inputfile = ".\sample.txt",
    [switch]$part2
)

function ProcessLine2 {
    param(
        [string]$str
    )

    write-verbose "$str ($($str.length))"

    $str = $str -replace "\\","\\"
    $str = $str -replace """","\"""

    $str = """" + $str + """"
    write-verbose "$str ($($str.length))"



    return $str.length
}
function ProcessLine {
    param(
        [string]$str
    )

    write-verbose "$str ($($str.length))"

    $m = $str | Select-String -pattern "\\x[01234567890abcdef]{2}" -AllMatches
    if($m.Matches.Count -gt 0) {
        foreach($match in $m.Matches) {
            write-verbose "  $($match.Value -replace "\\x") = $([char][convert]::toint16($match.Value.substring(2),16))"
            #$str = $str -replace "\$m",[char][convert]::toint16($m.substring(2),16)
            $str = $str -replace "\$($match.Value)",[char][convert]::toint16($match.Value.substring(2),16)
        }
    }

    $str = ($str -replace "^""") -replace """$" #trim start and end quotes
    $str = $str -replace "\\""","""" #replace escaped quote
    $str = $str -replace "\\\\","\" #replace escaped backslash

    write-verbose "$str ($($str.length))"

    return $str.length
}

$charcounts = @()
$memcounts = @()
$text = Get-Content $inputfile
foreach($line in $text) {
    $line = $line.trim()
    $charcounts += $line.length
    if($part2) { 
        $memcounts += ProcessLine2 $line
    } else {
        $memcounts += ProcessLine $line
    }   
    write-verbose ""
}

if($part2) {
    ($memcounts | measure-object -sum).sum - ($charcounts | measure-object -sum).sum
} else {
    ($charcounts | measure-object -sum).sum - ($memcounts | measure-object -sum).sum
}