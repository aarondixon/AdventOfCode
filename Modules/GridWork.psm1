
function Transpose-Matrix { # swap rows and columns. unfortunately, powershell doesn't have a quick/easy way to do this natively
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

Export-ModuleMember Transpose-Matrix