[cmdletbinding()]
param(
    $inputfile = ".\sample.txt",
    $first = "in",
    $max = 4000,
    $min = 1
)

class Part {
    [int]$x
    [int]$m
    [int]$a
    [int]$s

    Part($x,$m,$a,$s) {
        $this.x = $x
        $this.m = $m
        $this.a = $a
        $this.s = $s
    }

    [int]Sum() {
        return ($this.x + $this.m + $this.a + $this.s)
    }

    [string]ID() {
        return "{x=$($this.x),m=$($this.m),a=$($this.a),s=$($this.s)}"
    }
}

function Merge-Ranges ($ranges) {
    if (-not $ranges) {
        return @()
    } elseif($ranges.count -eq 1) {
        return ,$ranges
    }

    $sortedRanges = $ranges | Sort-Object { $_[0] }

    $result = @()
    $result += ,($sortedRanges[0][0],$sortedRanges[0][1])
    $index = 0

    for($i  = 1; $i -lt $sortedRanges.Count; $i++) {
        if($sortedRanges[$i][0] -le $result[$index][1]) { #overlapping
            $result[$index] = ($result[$index][0],[math]::Max($result[$index][1],$sortedRanges[$i][1]))
        } else {
            $index++
            $result += ,($sortedRanges[$i][0],$sortedRanges[$i][1])
        }
    }

    return ,$result
}

$flows = @{}
$text = (Get-Content $inputfile)

$ranges = @{}
$ranges["x"] = @()
$ranges["m"] = @()
$ranges["a"] = @()
$ranges["s"] = @()


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

foreach($flow in $flows.GetEnumerator()) {
    foreach($rule in $flow.Value) {
        $r = ($rule | Select-String "([xmas])([<>])(\d+):(.+)" -AllMatches)

        if($r) {
            write-verbose "    $rule"
            $att = $r.Matches.Groups[1].Value
            $op = $r.Matches.Groups[2].Value
            $val = $r.Matches.Groups[3].Value
            $act = $r.Matches.Groups[4].Value

            switch($op) {
                "<" { 
                    if($act -eq "A") { $ranges[$att] += ,($min,([int]$val-1)) }
                    $else[$att] += ,([int]$val,$max)
                }
                ">" { 
                    if($act -eq "A") { $ranges[$att] += ,(([int]$val+1),$max) }
                    $else[$att] += ,($min,[int]$val)
                }
            }
        } elseif ($rule -eq "A") {
            foreach($att in ("x","m","a","s")) {
                $ranges[$att] += $else[$att]
            }
        }
    }
}

$ranges

$total = 1
foreach($range in ("x","m","a","s")) {
    $merged = Merge-Ranges $ranges[$range]
    $sum = 0
    foreach($r in $merged) {
        $sum += $r[1] - $r[0] + 1
    }
    $total = $total * $sum
}

$total