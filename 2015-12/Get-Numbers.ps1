[cmdletbinding()]
param(
    $inputfile = ".\input.txt",
    [switch]$Part2
)

function Get-Sum {
    param(
        $jsonobject,
        $total
    )

    write-verbose "$jsonobject"

    if($jsonobject.GetType().Name -eq "String") {
        write-verbose "!"
        return ([int]::TryParse($jsonobject) | Out-Null)
    }

    foreach($prop in $jsonobject.psobject.properties) {
        if($prop.Value -eq "red") {
            return 0
        }

        write-verbose "  $($prop.GetType().Name)"
        switch($prop.GetType().Name) { 
            "PSNoteProperty" { 
                $total += Get-Sum $prop $total
            }
            "String" {
                $total += [int]::TryParse($prop.Value) | Out-Null
            }
            "Object[]" {
                foreach($obj in $prop) {
                    $total += Get-Sum $obj $total
                }
            }
        }
    }

    return $total
}

$text = Get-Content -Raw $inputfile

if($Part2) {  
    $json = ConvertFrom-Json $text -depth 100
    $total = Get-Sum $json 0
    $total
    exit
} else {
    ($text | Select-String -pattern "-?\d+" -AllMatches).Matches.Value | Measure-Object -Sum | Select-Object sum
    exit
}


