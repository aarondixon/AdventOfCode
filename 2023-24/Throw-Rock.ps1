[cmdletbinding()]
param(
    $inputfile = "input.txt"   
)

function add(A, B, hails, n) {
    const [px0, py0, pz0, vx0, vy0, vz0] = hails[0]
    const [pxN, pyN, pzN, vxN, vyN, vzN] = hails[n]
    A.push([vy0 - vyN, vxN - vx0, 0n, pyN - py0, px0 - pxN, 0n])
    B.push(px0 * vy0 - py0 * vx0 - pxN * vyN + pyN * vxN)
    A.push([vz0 - vzN, 0n, vxN - vx0, pzN - pz0, 0n, px0 - pxN])
    B.push(px0 * vz0 - pz0 * vx0 - pxN * vzN + pzN * vxN)
}

function det(m) {
    if (m.length == 0) return 1n
    let [l, ...r] = m
    r = l.map((n, i) => n * det(r.map(row => row.toSpliced(i, 1))))

    return r.reduce((a, b, i) => (i % 2 ? a - b : a + b), 0n)
}

function cramer(A, B) {
    const detA = det(A)
    return A.map((_, i) => det(A.map((r, j) => r.toSpliced(i, 1, B[j]))) / detA)
}

$hails = @()
foreach($line in (Get-Content $inputfile)) {
    $coords = $line -replace "@",""
}
const hails = input.split('\n').map(line => line.match(/-?\d+/g).map(BigInt))
const A = []
const B = []
for (let i = 1; i <= 3; i++) add(A, B, hails, i)
const [pxr, pyr, pzr] = cramer(A, B)
return pxr + pyr + pzr