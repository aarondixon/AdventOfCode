[cmdletbinding()]
param(
    $text = "^v^v^v^v^v"
)

#store x,y values to increment by based on direction
$dirs = @{}
$dirs[[char]'^'] = 0,1
$dirs[[char]'>'] = 1,0
$dirs[[char]'v'] = 0,-1
$dirs[[char]'<'] = -1,0

#initialize x and y locations for Santa,Robo-Santa
$x = 0,0
$y = 0,0

#initialize houses hashtable; each key will be x,y of a house location, value will be number of times visited
$houses = @{}
$houses["0,0"] = 2 #start at 2 because both Santa and Robo-Santa start at 0,0

#iterate through instructions
for($i = 0; $i -lt $text.length; $i++) {
    $turn = $i % 2 #determine whose turn it is by alternating between 0 and 1 for even and odd (0 = Santa, 1 = Robo-Santa). Could easily scale to more deliverers with essentially no performance hit
    #write-verbose "$i ($turn) : $($text[$i]) = $($dirs[$text[$i].ToString()])"
    $x[$turn] += ($dirs[$text[$i]])[0] #modify x value of current deliverer based on instruction
    $y[$turn] += ($dirs[$text[$i]])[1] #modify y value of current deliverer based on instruction
    #write-verbose "$($x[$turn]),$($y[$turn])"

    $houses["$($x[$turn]),$($y[$turn])"]++ #increment visits at house at x,y
}

write-output $houses.Keys.count #display number of houses visited. Use ($houses.Values | ? {$_ -gt #}).Count to determine number of houses with more than # presents