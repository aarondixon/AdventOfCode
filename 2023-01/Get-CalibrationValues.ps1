[cmdletbinding()]
param(
    $inputfile = "input.txt"
)

function FirstOfAny {
    param($test,$values)
    [int]$first = -1
    $found = ""

    foreach($item in $values) {
        $i = $test.indexOf($item)
        if($i -ge 0) {
            write-verbose "$item ($i)"
            if($first -gt 0) {
                if($i -lt $first) {
                    $first = $i
                    $found = $item
                }
            } else {
                $first = $i
                $found = $item
            }
        }
    }

    if($null -eq ($foundnum = $found -as [int])) {
        $foundnum = $values.IndexOf($found)+1
    }

    Write-Verbose "First: $found ($foundnum)"
    return $foundnum
}

function LastOfAny {
    param($test,$values)
    [int]$last = -1
    $found = ""

    foreach($item in $values) {  
        $i = $test.indexOf($item)
        if($i -ge 0) {
            if($last -gt 0) {
                if($i -gt $last) {
                    $last = $i
                    $found = $item
                }
            } else {
                $last = $i
                $found = $item
            }
        }
    }
    
    if($null -eq ($foundnum = $found -as [int])) {
        $foundnum = $values.IndexOf($found)+1
    }

    Write-Verbose "Last: $found ($foundnum)"
    return $foundnum
}

$text = get-content $inputfile
$sum = 0
$terms = 'one','two','three','four','five','six','seven','eight','nine','0','1','2','3','4','5','6','7','8','9'

Write-Verbose "Terms: $terms"

foreach($l in $text) {
    #$nums = $l -replace "[^0-9]",""
    #$num = $nums[0] + $nums[$nums.Length-1]

    #$num1 = (FirstOfAny -test $l -values $terms)
    #$num2 = (LastOfAny -test $l -values $terms)

    $results = @()
    foreach($t in $terms) {
        $results += [regex]::Matches($l,$t)
    }

    $results = $results | sort Index

    $digit1 = $results[0].Value
    $digit2 = $results[$results.Count-1].Value

    if($null -eq ($num1 = $digit1 -as [int])) {
        $num1 = [int]($terms.IndexOf($digit1)+1)
    }
    if($null -eq ($num2 = $digit2 -as [int])) {
        $num2 = [int]($terms.IndexOf($digit2)+1)
    }

    $num = [string]$num1 + [string]$num2

    Write-Verbose "line: $l"
    Write-Verbose "2-digit number: $num"

    $sum += [int]$num
}

$sum