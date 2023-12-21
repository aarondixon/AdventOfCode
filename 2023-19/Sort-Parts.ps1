[cmdletbinding()]
param(
    $inputfile = ".\sample.txt",
    $first = "in"
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

$flows = @{}
$parts = @()
$text = (Get-Content $inputfile)

$mode = "flows"
foreach($line in $text) {
    if($line.length -eq 0) {
        $mode = "parts"
        continue
    }

    switch($mode) {
        "flows" {
            $name = ($line -split "\{")[0]
            $rules = ($line -split "\{")[1].trimend("}").split(",")
            $flows[$name] = $rules
            write-verbose "$name = $rules"
        }

        "parts" {
            $att = ($line | Select-String -Pattern "(\d+)" -AllMatches).Matches.Value
            $parts += [Part]::new($att[0],$att[1],$att[2],$att[3])
        }
    }
}

$AcceptedParts = @()

foreach($part in $parts) {
    $rules = $flows[$first]
    $accepted = $false
    $rejected = $false
    write-verbose $part.ID()
    while(-not ($accepted -or $rejected)) {
        write-verbose "  $($rules -join ",")"
        foreach($rule in $rules) {
            $r = ($rule | Select-String "([xmas])([<>])(\d+):(.+)" -AllMatches)
            $action = ""
            if($r) {
                write-verbose "    $rule"
                $att = $r.Matches.Groups[1].Value
                $op = $r.Matches.Groups[2].Value
                $val = $r.Matches.Groups[3].Value
                $act = $r.Matches.Groups[4].Value

                switch($att) {
                    "x" { $dat = $part.x}
                    "m" { $dat = $part.m}
                    "a" { $dat = $part.a}
                    "s" { $dat = $part.s}
                }

                $result = $false
                switch($op) {
                    ">" { $result = $dat -gt $val}
                    "<" { $result = $dat -lt $val}
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

    if($accepted) {
        $AcceptedParts += $part
    }
}

$AcceptedParts.Sum() | Measure-object -Sum | Select-Object Sum