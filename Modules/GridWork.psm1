
function TransposeMatrix { # swap rows and columns. unfortunately, powershell doesn't have a quick/easy way to do this natively
    param(
        [object[]]$rows
    )

    $cols = @("") * $rows[0].Length
    foreach($row in $rows) {
        for($r = 0; $r -lt $row.length; $r++) {
            $cols[$r] += $row[$r]
        }
    }

    return $cols
}

function InBounds {
    param(
        $pos,
        $min,
        $max
    )

    return ($pos[0] -ge $min[0] -and $pos[0] -le $max[0] -and $pos[1] -ge $min[0] -and $pos[1] -le $max[1])
}

Export-ModuleMember InBounds
Export-ModuleMember Transpose-Matrix