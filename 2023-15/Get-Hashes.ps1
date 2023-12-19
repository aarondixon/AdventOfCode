using namespace System.Collections.Generic
[cmdletbinding()]
param(
    $inputfile = ".\input.txt",
    [switch]$test
)

class lens {
    [string]$label
    [int]$focallength

    lens($l,$f) {
        $this.label = $l
        $this.focallength = $f
    }
}

if($test) { 
    $text = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"
} else {
    $text = Get-Content $inputfile -Raw
}

function Get-Hash {
    param(
        [string]$str,
        $multiplier = 17,
        $divisor = 256
    )
    <#
    - Determine the ASCII code for the current character of the string.
    - Increase the current value by the ASCII code you just determined.
    - Set the current value to itself multiplied by 17.
    - Set the current value to the remainder of dividing itself by 256.
    #>

    $str = $str -replace [Regex]::Escape(([Environment]::NewLine)),""

    [int]$value = 0
    write-verbose $str
    for($i = 0; $i -lt $str.length; $i++) {
        write-verbose $value
        $ascii = [int]([char]$str[$i])
        $value = (($value + $ascii) * $multiplier) % $divisor
        write-verbose "  $value"
    }

    #write-verbose $value
    return $value
}

#boxes 0 - 255 (256 ct)
#step:
# lens label (sequence of letters) of box. HASH(label) = box number
# operator (= or -)
#  if -: remove lens with label from box, move all lenses forward in order 
#  if =: followed by focal length (1-9), mark lens with label
#    if already lens with that label in box, replace old lens with new, no moving other lenses
#    if not lens in box with that label, add lens behind lenses already in box
#
#focusing power: 1 + box number of lens * slot number of lens (1-based index) * focal length of lens
# sum focusing powers of all lensese

$boxes = [ordered]@{ }

for($i = 0; $i -lt 256; $i++) {
    $boxes.Add($i,[ordered]@{})
}

foreach($step in $text -split ",") {
    if($step.EndsWith("-")) {
        $operator = "-"
        $label = $step.TrimEnd("-")
    } else {
        $operator = "="
        $label = ($step -split "=")[0]
        $focallength = ($step -split "=")[1]
    }

    $box = [int](Get-Hash $label)
    write-verbose "$label = $box"
    switch($operator) {
        "=" {
            if($boxes[$box].Contains($label)) {
                $boxes[$box][$label] = $focallength
            } else {
                $boxes[$box].Add($label,$focallength)
            }
        }

        "-" {
            if($boxes[$box].Contains($label)) {
                $boxes[$box].Remove($label)
            }
        }
    }
}

$total = 0
for($i = 0; $i -lt 256; $i++) {
    for($j = 0; $j -lt $boxes[$i].Keys.Count; $j++) {
        Write-verbose "box $i, lens $j"
        $total += (1 + $i) * (1 + $j) * $boxes[$i][$j]
    }
}

$total