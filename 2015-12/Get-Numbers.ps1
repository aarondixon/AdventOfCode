[cmdletbinding()]
param(
    $inputfile = ".\input.txt",
    [switch]$Part2
)

$text = Get-Content -Raw $inputfile

if($Part2) {  
    $json = ConvertFrom-Json $text -depth 100
} else {
    ($text | Select-String -pattern "-?\d+" -AllMatches).Matches.Value | Measure-Object -Sum | Select-Object sum
}
