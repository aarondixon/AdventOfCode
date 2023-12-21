[cmdletbinding()]
param(
    $inputfile = ".\sample.txt",
    $first = "in",
    $keys = ("x","m","a","s")
)

$ranges = @{}
$flows = @{}

function GetAcceptedRange {
    param(
        $flow,
        [hashtable]$rangein
    )

    $rules = $flows[$flow]

    $rangesout = @() # list of 4-element hashtables


    foreach($rule in $rules) {
        $r = ($rule | Select-String "([xmas])([<>])(\d+):(.+)" -AllMatches)
        $max = @{}
        $min = @{}
        foreach($a in $keys) {
            $max[$a] = $rangein[$a][1]
            $min[$a] = $rangein[$a][0]
            #write-verbose "$a : $($min[$a]) - $($max[$a])"
        }        

        if($r) {
            write-verbose "    $rule"
            $att = $r.Matches.Groups[1].Value
            $op = $r.Matches.Groups[2].Value
            $val = [int]$r.Matches.Groups[3].Value
            $act = $r.Matches.Groups[4].Value

            switch($op) {
                ">" { 
                    if($max[$att] -le $val) { continue }
                    $newrange = $rangein.clone()
                    $newrange[$att] = ([math]::max($val+1,$min[$att]),$max[$att])
                    if($act -eq "A") { 
                        $rangesout += $newrange.clone()
                    } elseif($act -ne "R") {
                        $rangesout += (GetAcceptedRange $act $newrange)
                    }
                    #if($act -eq "R") {  }
                    #$passrange = $rangein.clone()
                    #$passrange[$att] = ($min[$att],[math]::min($val,$max[$att]))
                    #$rangein = $passrange
                    $rangein[$att] = ($min[$att],[math]::min($val,$max[$att]))
                }
                "<" { 
                    if($min[$att] -ge $val) { continue }
                    $newrange = $rangein.clone()
                    $newrange[$att] = ($min[$att],[math]::min($max[$att],$val-1))
                    if($act -eq "A") {                         
                        $rangesout += $newrange.clone()
                    }  elseif($act -ne "R") {
                        $rangesout += (GetAcceptedRange $act $newrange)
                    }
                    #if($act -eq "R") { break }
                    #$passrange = $rangein.clone()
                    #$passrange[$att] = ([math]::max($min[$att],$val),$max[$att])
                    #$rangein = $passrange
                    $rangein[$att] = ([math]::max($min[$att],$val),$max[$att])
                }
            }
        } else {
            if($rule -eq "A") {
                write-verbose "  A"
                $rangesout += $rangein.clone()
            } elseif($rule -eq "R") {
                write-verbose "  R"
            } else {
                write-verbose "  -> $rule"
                $rangesout += (GetAcceptedRange $rule $rangein)
            }
        }
    }

    return $rangesout
}

$text = (Get-Content $inputfile)

foreach($a in $keys) {
    $ranges[$a] = @((1,4000))
}

#read in all flows
foreach($line in $text) {
    if($line.length -eq 0) {
        break
    }

    $name = ($line -split "\{")[0]
    $rules = ($line -split "\{")[1].trimend("}").split(",")
    $flows[$name] = $rules
    write-verbose "$name = $rules"
}

$acceptable = (GetAcceptedRange $first $ranges)
$sum = 0
foreach($set in $acceptable) {
    $prod = 1
    $set
    foreach($v in $set.values) {
        write-verbose "$($v[1]) - $($v[0])"
        $prod = $prod * ($v[1] - $v[0] + 1)
    }
    $sum += $prod
}

$sum