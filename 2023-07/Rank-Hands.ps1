[cmdletbinding()]
param(
    $text = (Get-Content "sample.txt")
)

[char[]]$CardValues = 'J','2','3','4','5','6','7','8','9','T','Q','K','A'

enum HandType : int {
    FiveOfAKind = 70
    FourOfAKind = 60
    FullHouse = 50
    ThreeOfAKind = 40 
    TwoPair = 30
    OnePair = 20
    HighCard = 10
}

function CalculateValue($cards) {
    [int]$val = 0
    for($i = 0; $i -lt $cards.length; $i++) {
        $val += $CardValues.IndexOf($cards[$i]) * [math]::pow(13,$cards.length - $i - 1)
    }

    return $val
}

class Hand {
    [string]$Cards
    [int]$Bid
    [HandType]$Type
    [int]$Value
    [int]$Score

    Hand($cards,$bid) {
        $this.Cards = $cards
        $this.Bid = $bid
        $this.Type = GetHandType($cards)
        $this.Value = CalculateValue($cards)
    }

    SetScore($score) {
        $this.Score = $score
    }
}

function GetHandType {
    param(
        [char[]]$cards
    )


    $groups = $cards | group-object
    if($groups.length -eq 1) {
        #all 5 cards are the same, return five of a kind
        return [HandType]::FiveOfAKind
    }

    if($cards -notcontains 'J' -or $CardValues[0] -eq '2') { 
        if(($groups | select-object -ExpandProperty count | measure-object -maximum | select-object -ExpandProperty maximum) -eq 4) {
            #4 cards are same, return 4 of a kind
            return [HandType]::FourOfAKind
        }

        if($groups.length -eq 2) {
            #2 groups, already know it's not 4 of a kind, return full house
            return [HandType]::FullHouse
        }

        if(($groups | select-object -ExpandProperty Count | measure-object -maximum | select-object -ExpandProperty maximum) -eq 3) {
            #we know there are at least 3 different cards, if the maximum of a unique card is 3, return 3 of a kind
            return [HandType]::ThreeOfAKind
        }

        if($groups.length -eq 3) {
            #3 groups, already know it's not 3 of a kind, return two pair
            return [HandType]::TwoPair
        }

        if(($groups | select-object -ExpandProperty Count | Measure-Object -maximum | select-object -ExpandProperty maximum) -eq 2) {
            #we know there are at least 4 different cards, if the maximum of a unique card is 2, return one pair
            return [HandType]::OnePair
        }

        return [HandType]::HighCard
    } else {
        if(($groups | select-object -ExpandProperty count | measure-object -maximum | select-object -ExpandProperty maximum) -eq 4) {
            #4 cards are same, only can be one J, return 5 of a kind
            return [HandType]::FiveOfAKind
        }

        if($groups.length -eq 2) {
            #2 groups, already know it's not 4 of a kind, full house must be JJ### or JJJ##, either way 5 of a kind is best hand
            return [HandType]::FiveOfAKind
        }

        if(($groups | select-object -ExpandProperty Count | measure-object -maximum | select-object -ExpandProperty maximum) -eq 3) {
            #we know there are at least 3 different cards, if the maximum of a unique card is 3, it's a 3 of a kind. But with
            #2 Js, it would already be a full house. JJJ#* and J###* both result in 4 of a kind
            return [HandType]::FourOfAKind
        }

        if($groups.length -eq 3) {
            #3 groups, already know it's not 3 of a kind -- can only be 1 or 2 Js, J##** or JJ##*
            $numJs = ($groups | Where-Object {$_.Name -eq 'J'}).Count
            if($numJs -eq 1) { return [HandType]::FullHouse }
            if($numJs -eq 2) { return [HandType]::FourOfAKind}
        }

        if(($groups | select-object -ExpandProperty Count | Measure-Object -maximum | select-object -ExpandProperty maximum) -eq 2) {
            #we know there are at least 4 different cards, if the maximum of a unique card is 2, return one pair
            # ##J*@ JJ#*@
            return [HandType]::ThreeOfAKind
        }   
        return [HandType]::OnePair     
    }


}

function CompareHands {
    param(
        [Hand]$ReferenceHand,
        [Hand]$DifferenceHand
    )

    #return -1 if Reference is lower, 0 if equal, 1 if Reference is higher

    if($ReferenceHand.Type -gt $DifferenceHand.Type) {
        write-verbose "  $($ReferenceHand.Cards) ($($ReferenceHand.Type)) > $($DifferenceHand.cards) ($($DifferenceHand.Type))"
        return 1
    } elseif ($ReferenceHand.Type-lt $DifferenceHand.Type) {
        write-verbose "  $($ReferenceHand.Cards) ($($ReferenceHand.Type)) < $($DifferenceHand.cards) ($($DifferenceHand.Type))"
        return -1
    } else {
        if($ReferenceHand.Value -gt $DifferenceHand.Value) {
            write-verbose "  $($ReferenceHand.Cards) ($($ReferenceHand.Value)) > $($DifferenceHand.Cards) ($($DifferenceHand.Value))"
            return 1
        } elseif ($ReferenceHand.Value -lt $DifferenceHand.Value) {
            write-verbose "  $($ReferenceHand.Cards) ($($ReferenceHand.Value)) < $($DifferenceHand.Cards) ($($DifferenceHand.Value))"
            return -1
        } else {
            write-verbose "  $($ReferenceHand.Cards) = $($DifferenceHand.Cards)"
            return 0
        }
    }
}

$hands = [System.Collections.Generic.List[Object]]::new()
foreach($line in $text) {
    $hand = [Hand]::new(($line -split " ")[0],($line -split " ")[1])

    Write-Verbose $hand.Cards

    if($hands.count -eq 0) {
        $hands.Add($hand)
        continue
    }

    for($i = $hands.count-1; $i -ge 0; $i--) {
        if((CompareHands -ReferenceHand $hand -DifferenceHand $hands[$i]) -ge 0) {
            Write-Verbose "Inserting at $i"
            $hands.Insert($i+1,$hand)
            break
        }
        if($i -eq 0) { 
            $hands.insert(0,$hand)
            write-verbose "  inserted at 0"
            break
        }        
    }
}

$result = 0
for($h = 0; $h -lt $hands.count; $h++) {
    [Hand]$hands[$h].SetScore($hands[$h].Bid * ($h+1))
}

$hands | ft
($hands.Score | Measure-Object -Sum).Sum