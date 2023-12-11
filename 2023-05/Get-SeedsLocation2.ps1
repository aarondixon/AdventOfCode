[cmdletbinding()]
param(
    $text = (get-content "sample.txt")
)

#maps[sourcetype]
#map
# destinationtype
# ranges
#  destination start
#  source start
#  length

#read data
$seeds = @()
$maps = @{}
foreach($line in $text) {
    if($line.indexof(":") -ge 0) {
        $heading = ($line -split ":")[0].trim()
        Write-Verbose "Heading: $heading"
        if($heading -eq "seeds") {
            $seedlist = ($line -split ":")[1].trim() -split "\s+"
            for($i = 0; $i -lt $seedlist.count; $i++) {
                if($i % 2 -eq 0) {
                    write-verbose "  $($seedlist[$i])"
                    $seeds += [int64]$seedlist[$i]..([int64]$seedlist[$i]+[int64]$seedlist[$i+1]-1)
                    $i += 1
                }
            }
        } else {
            $sourceType = ($heading -split "-")[0]
            $destinationType = ($heading-split "-")[2] -replace " map",""
            Write-Verbose "  $sourceType -> $destinationType"
            $maps[$sourceType] = @{}
            $maps[$sourceType].destinationType = $destinationType
            $maps[$sourceType].ranges = @()
        }        
    } else {
        $values = $line -split "\s+"
        if($values.count -eq 3) {
            $maps[$sourceType].ranges += @{destinationStart = [int64]$values[0]; sourceStart = [int64]$values[1]; length = [int64]$values[2]}
        }
    }
}

write-verbose "seeds: $($seeds -join "; ")"

$locations = @()
foreach($seed in $seeds) {
    $source = "seed"
    [int64]$value = $seed
    do {
        write-verbose ("{0}: {1}" -f $source,$value)
        foreach($range in $maps[$source].ranges) {
            if($value -ge $range.sourceStart -and $value -lt ($range.sourceStart + $range.length)) {
                write-verbose "  range: $($range.sourceStart) - $($range.sourceStart + $range.length)"
                $value = $range.destinationStart + ($value - $range.sourceStart)
                break
            }
        }       
        $source = $maps[$source].destinationType
        Write-Verbose ""
    } while ($maps.keys -contains $source)
    $locations += $value
    write-verbose "$seed -> $value"
}

$locations | measure-object -minimum | select -expandproperty minimum