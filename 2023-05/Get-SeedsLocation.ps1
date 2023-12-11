[cmdletbinding()]
param(
    $text = (get-content "input.txt")
)

class Range {
    [int64]$Start
    [int64]$End

    Range([int64]$s, [int64]$e) {
        $this.Start = $s
        $this.End = $e
    }
}

class Map {
    $Ranges
    [string]$DestinationType

    Map([string]$type) {
        $this.Ranges = @()
        $this.DestinationType = $type
    }
}

#maps[sourcetype]
#map
# destinationtype
# ranges
#  destination start
#  source start
#  length

#read data
$seedranges = @()
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
                    $seedranges += [Range]::new([int64]$seedlist[$i],([int64]$seedlist[$i]+[int64]$seedlist[$i+1]-1))
                    $i += 1
                }
            }
        } else {
            $sourceType = ($heading -split "-")[0] -replace " map",""
            $destinationType = ($heading-split "-")[2] -replace " map",""
            Write-Verbose "  $sourceType -> $destinationType"
            $maps[$sourceType] = [Map]::new($destinationType)
        }        
    } else {
        $values = $line -split "\s+"
        if($values.count -eq 3) {
            $maps[$sourceType].Ranges += @{SourceRange = [Range]::new([int64]$values[1], [int64]$values[1]+[int64]$values[2]-1); DestinationRange = [Range]::new([int64]$values[0],[int64]$values[0]+[int64]$values[2]-1)}
        }
    }
}

function MapRanges {
    param(
        [Range[]]$InputRanges,
        $MapRanges
    )

    $DestinationRanges = @()

    for($i = 0; $i -lt $MapRanges.Count; $i++) {
        $MapRange = $MapRanges[$i].SourceRange
        $DestRange = $MapRanges[$i].DestinationRange

        Write-Verbose "$i"
        Write-Verbose "  Map Range: $($MapRange.Start)..$($MapRange.End)"
        Write-Verbose "  Destination Range: $($DestRange.Start)..$($DestRange.End)"
        $tempRanges = @()
        foreach($InputRange in $InputRanges) {
            Write-Verbose "    Input Range: $($InputRange.Start)..$($InputRange.End)"
            #if a section of the input range doesn't match the map range, add it to tempRanges to be processed in next map range
            #if a section of the input range does map the map range, translate it and add it to destination ranges to be returned
             
            if($InputRange.Start -lt $MapRange.Start) {
                #input range starts below map range
                if($InputRange.End -lt $MapRange.Start) {
                    #entire input range is below map range
                    $tempRanges += $InputRange
                } elseif($InputRange.End -le $MapRange.End) {
                    #input range starts before map range, but ends within map range; need to split
                    $tempRanges += [Range]::new($InputRange.Start,$MapRange.Start-1)
                    $DestinationRanges += [Range]::new($DestRange.Start,$DestRange.Start + ($InputRange.End-$MapRange.Start))
                } else {
                    #input range starts before map range and ends after map range
                    $tempRanges += [Range]::new($InputRange.Start,$MapRange.Start-1)
                    $DestinationRanges += [Range]::new($DestRange.Start,$DestRange.End)
                    $tempRanges += [Range]::new($MapRange.End+1,$InputRange.End)
                }
            } elseif ($InputRange.Start -ge $MapRange.Start -and $InputRange.Start -le $MapRange.End) {
                #input range starts in map range
                if($InputRange.End -le $MapRange.End) {
                    #entire input range is within map range, translate whole input range
                    $DestinationRanges += [Range]::new($DestRange.Start + ($InputRange.Start - $MapRange.Start), $DestRange.Start + ($InputRange.End - $MapRange.Start))
                } else {
                    #input range starts within map range, ends outside of map range; need to split
                    $DestinationRanges += [Range]::new($DestRange.Start + ($InputRange.Start - $MapRange.Start), $DestRange.End )
                    $tempRanges += [Range]::new($MapRange.End+1,$InputRange.End)
                }
            } else {
                #source range starts (and ends) outside of map range
                $tempRanges += $InputRange
            }
            
            <#
            $left = [Range]::new($InputRange.Start, (($InputRange.End,$MapRange.Start) | Measure-Object -Minimum).Minimum)
            $mid = [Range]::new((($InputRange.Start, $MapRange.Start) | Measure-Object -Maximum).Maximum, (($MapRange.End, $InputRange.End) | Measure-Object -Minimum).Minimum)
            $right = [Range]::new((($MapRange.End, $InputRange.Start) | Measure-Object -Maximum).Maximum, $InputRange.End)

            if($left.End -gt $left.Start) {
                $tempRanges += $left
            }
            if($mid.End -gt $mid.Start) {
                $DestinationRanges += [Range]::new($mid.Start - $MapRange.Start + $DestRange.Start, $mid.End - $MapRange.Start + $DestRange.Start)
            }
            if($right.End -gt $right.Start) {
                $tempRanges += $right
            }
            #>
        }
        $InputRanges = $tempRanges
    }
    Write-Verbose "$($InputRanges.count) input ranges -> $($DestinationRanges.count) destination ranges"
    return $DestinationRanges + $InputRanges
}

$currentRanges = $seedranges
$source = "seed"
do {
    Write-Verbose "$source -> $($maps[$source].DestinationType)"
    $currentRanges = MapRanges -InputRanges $currentRanges -MapRanges $maps[$source].Ranges
    $source = $maps[$source].DestinationType
} while ($maps.keys -contains $source)

#$currentRanges

$currentRanges.Start | Measure-Object -Minimum | Select-Object -ExpandProperty Minimum