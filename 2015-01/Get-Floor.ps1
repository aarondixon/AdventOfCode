[cmdletbinding()]
param(
    $text = (Get-Content ".\input.txt")
)

$instructions = $text -replace "`n",""

($instructions.ToCharArray() | Where-Object {$_ -eq "("}).Count - ($instructions.ToCharArray() | Where-Object {$_ -eq ")"}).Count