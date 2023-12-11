function IsPointInsidePolygon {
    param (
        [double]$pointX,
        [double]$pointY,
        [double[]]$polygonVerticesX,
        [double[]]$polygonVerticesY
    )

    $verticesCount = $polygonVerticesX.Length
    $isInside = $false
    $j = $verticesCount - 1

    for ($i = 0; $i -lt $verticesCount; $i++) {
        $xi = $polygonVerticesX[$i]
        $yi = $polygonVerticesY[$i]
        $xj = $polygonVerticesX[$j]
        $yj = $polygonVerticesY[$j]

        $intersect = (($yi -le $pointY -and $yj -gt $pointY) -or ($yj -le $pointY -and $yi -gt $pointY)) -and
                      ($pointX -lt ($xj - $xi) * ($pointY - $yi) / ($yj - $yi) + $xi)

        if ($intersect) {
            $isInside = -not $isInside
        }

        $j = $i
    }

    return $isInside
}

# Example usage
$pointX = 2
$pointY = 2
$polygonVerticesX = @(1, 1, 3, 3)
$polygonVerticesY = @(1, 3, 3, 1)

$isInside = IsPointInsidePolygon -pointX $pointX -pointY $pointY -polygonVerticesX $polygonVerticesX -polygonVerticesY $polygonVerticesY

if ($isInside) {
    Write-Host "The point ($pointX, $pointY) is inside the polygon."
} else {
    Write-Host "The point ($pointX, $pointY) is outside the polygon."
}
