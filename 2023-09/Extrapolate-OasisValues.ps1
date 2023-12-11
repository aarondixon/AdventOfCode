[cmdletbinding()]
param(
    $text = (Get-Content ".\sample.txt"),
    [switch] $reverse
)

function Extrapolate {
    param(
        [int64[]]$vals,
        [int64]$offset
    )

    #Write-Verbose ("{0}{1}" -f (" "*$offset),($vals -join "   "))

    if(($vals[0] -eq 0) -and ($vals | group-object ).length -eq 1) { $result = 0} else {
        $newvals = @()
        for($v = 1; $v -lt $vals.length; $v++) {
            $newvals += $vals[$v]-$vals[$v-1]
        }
        if($reverse) {
            $result = $vals[0] - (Extrapolate -vals $newvals -offset ($offset +2))
        } else {
            $result = $vals[$vals.length-1] + (Extrapolate -vals $newvals -offset ($offset +2))
        }
        
    }
    if($reverse) {
        write-verbose ("{0}[{1}]   {2}" -f (" "*$offset),$result,($vals -join "   "))
    } else {
        Write-Verbose ("{0}{1}   [{2}]" -f (" "*$offset),($vals -join "   "),$result)        
    }
    
    return $result    

}

[int64]$sum = 0
foreach($line in $text) {
    [int64[]]$values = $line -split "\s+"
    [int64]$newval = (Extrapolate -vals $values -offset 0)
    $sum += $newval
}

$sum