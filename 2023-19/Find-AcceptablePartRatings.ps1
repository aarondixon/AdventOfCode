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


$ranges = @{}
$flows = @{}

function GetAcceptedRange {
    param(
        $flow,
        $range
    )

    $rules = $flows[$flow]

    $count = 0

    foreach($rule in $rules) {
        $r = ($rule | Select-String "([xmas])([<>])(\d+):(.+)" -AllMatches)
        $action = ""
        if($r) {
            write-verbose "    $rule"
            $att = $r.Matches.Groups[1].Value
            $op = $r.Matches.Groups[2].Value
            $val = $r.Matches.Groups[3].Value
            $act = $r.Matches.Groups[4].Value

            $result = $false
            switch($op) {
                ">" { 
                    if($act -eq "A") { $range[$att] = ($val+1,$max); break } 
                    if($act -eq "R") { break }
                    GetAcceptedRange
                }
                "<" { if($act -eq "A") { $ranges[$att] += ,($min,$val-1) } }
            }

            if($result) { $action = $act }
        } else {
            write-verbose "    $action"
            $action = $rule
        }

        if($action -eq "R") {
            write-verbose "      $result -> REJECTED"
            $rejected = $true
            break
        } elseif($action -eq "A") {
            write-verbose "      $result -> ACCEPTED"
            $accepted = $true
            break
        } elseif($action -ne "") {
            write-verbose "      $result -> $action"
            $rules = $flows[$action]
            break
        }
    }

}


$text = (Get-Content $inputfile)

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

GetAcceptedRange $first
