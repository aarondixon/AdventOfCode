[cmdletbinding()]
param(
    $inputfile = ".\sample.txt"
)

$text = (Get-Content $inputfile)

$cols = @("") * $text[0].Length
foreach($line in $text) {
    for($r = 0; $r -lt $line.Length; $r++) {
        $cols[$r] += $line[$r]
    }
}

$totalweight = 0
$newcols = @()
foreach($col in $cols) {
    Write-Verbose "$col"
    $weight = 0
    $newsecs = @()
    $blocks = @(0) + ($col | Select-String -Pattern "#" -AllMatches).Matches.Index
    Write-Verbose "  Blocks: $blocks"
    $secs = $col -split "#"
    for($s = 0; $s -lt $secs.count; $s++) {
        $sec = $secs[$s] -replace "\.",""
        write-verbose "  $($secs[$s]) -> $sec"
        $newsecs += $sec + "." * ($secs[$s].length - $sec.length)
        for($r = 0; $r -lt $sec.length; $r++) {
            $weight += $col.Length - ($blocks[$s] + $r + ($s -gt 0 ? 1 : 0))
        }
    }

    $newcols += $newsecs -join "#"
    write-verbose "  Weight: $weight"
    $totalweight += $weight
}

$totalweight

for($r = 0; $r -lt $text[0].length; $r++) {
    $row = ""
    foreach($c in $newcols) {
        $row += $c[$r]
    }
    write-output "$row $($text.count - $r)"
}