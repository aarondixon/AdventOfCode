[cmdletbinding()]
param(
    $key = "abcdef"
)

$md5 = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
$utf8 = new-object -TypeName System.Text.UTF8Encoding
$i = 1
do {  
    $str = "$key$i"
    $hash = [System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes("$str")))
    #write-verbose "Checking $str : $hash"
    $i++
} while (-not $hash.StartsWith("00-00-00"))

$hash
$i - 1