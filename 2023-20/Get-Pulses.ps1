[cmdletbinding()]
param(
    $inputfile = ".\sample1.txt",
    $pushes = 10,
    $target = "rx"
)

Class Pulse {
    [int16]$Value
    [string]$Source
    [string]$Target

    Pulse($s,$t,$v) {
        $this.Value = $v
        $this.Source = $s
        $this.Target = $t
    }
}

Class FlipFlop {
#Flip-flop (%): on/off, initially off
#  HIGH PULSE: Nothing
#  LOW PULSE: flips on/off (on -> high pulse, off -> low pulse)    
    [string[]]$OutputModule
    [string[]]$InputModule
    [string]$Id
    [bool]$On
    
    FlipFlop($id) {
        $this.Id = $id
        $this.OutputModule = @()
        $this.InputModule = @()
        $this.On = $false
    }

    [void]AddInput($in) {
        $this.InputModule += $in
    }

    [int16]Update($in,$pulse) {
        if($pulse -eq -1) {
            $this.On = (-not $this.On)
            if($this.On) {
                return 1
            } else {
                return -1
            }
        } else {
            return 0
        }
    }
}

class Conjunction {
#Conjunction (&): remembers most recent pulse type of inputs, initially all inputs low
#  Updates memory when pulse received
#  if all inputs are high, sends low pulse; otherwise, sends high pulse    
    [string[]]$OutputModule
    [string[]]$InputModule
    [string]$Id
    [hashtable]$Pulse

    Conjunction($id) {
        $this.Id = $id
        $this.OutputModule =@()
        $this.InputModule = @()
        $this.Pulse = @{}
    }

    [void]AddInput($in) {
        $this.Pulse[$in] = -1
        $this.InputModule += $in
    }

    [int16]Update($in,$pulse) {
        $this.Pulse[$in] = $pulse
        if($this.Pulse.Values -notcontains -1) {
            return -1
        } else {
            return 1
        }
    }
}

Class Broadcast {
#Broadcast (named broadcaster): sends received pulse to all destination modules
    [string[]]$OutputModule
    [string]$Id

    Broadcast() {
        $this.Id = "broadcaster"
        $this.OutputModule = @()
    }

    [int16]Update($in,$pulse) {
        return $pulse
    }
}

$modules = @{}
$locount = 0
$hicount = 0

foreach($line in (Get-Content $inputfile)) {
    $parts = $line -split "->"
    $modname = $parts[0].trim()
    $outputs = ($parts[1].trim() -replace "\s+","") -split ","
    write-verbose "$modname -> $outputs"
    switch($modname.substring(0,1)) {
        "b" { $mod = [Broadcast]::new() }
        "%" { $mod = [FlipFlop]::new($modname.substring(1)) }
        "&" { $mod = [Conjunction]::new($modname.substring(1)) }
    }
    $mod.OutputModule = $outputs
    $modules[$mod.Id] = $mod
}

foreach($conjunction in ($modules.Values | where-object { $_.GetType().Name -eq "Conjunction" })) {
    foreach($mod in ($modules.Values)) {
        if($mod.OutputModule -contains $conjunction.Id) {
            $modules[$conjunction.Id].AddInput($mod.Id)
        }
    }
}

for($p = 0; $p -lt $pushes; $p++) { #PUSH THE BUTTON
    Write-Progress -Activity "Pushing Button" -PercentComplete ($p / $pushes * 100)
    write-verbose "`n`n***** PUSH $($p+1) *****`n"
    $Q = New-Object System.Collections.Queue
    $Q.Enqueue([Pulse]::new("button","broadcaster",-1))
    while($Q.Count -gt 0) {
        [Pulse]$pulse = $Q.Dequeue()
        write-verbose ("{0} -{1}-> {2}" -f $pulse.Source,($pulse.Value -gt 0 ? "hi" : ($pulse.Value -lt 0 ? "lo" : "??")),$pulse.Target)
        switch($pulse.Value) {
            -1 { $locount++ }
            1  { $hicount++ }
        }
        if($pulse.Target -eq $target -and $pulse.Value -eq -1 ) {break}
        if($modules.ContainsKey($pulse.Target)) {
            $val = $modules[$pulse.Target].Update($pulse.Source,$pulse.Value)
            if($val -ne 0) {
                foreach($out in $modules[$pulse.Target].OutputModule) {
                    $Q.Enqueue([Pulse]::new($pulse.Target,$out,$val))
                }
            }
        }
    }
    if($pulse.Target -eq $target -and $pulse.Value -eq -1) { break }
}

write-output "Pushes: $p Hi: $hicount Lo: $locount Prod: $($hicount * $locount)"
