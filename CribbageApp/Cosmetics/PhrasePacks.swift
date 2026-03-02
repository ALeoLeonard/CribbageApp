import Foundation

// MARK: - Classic Phrase Pack

/// Mirrors the original hardcoded callout text exactly.
struct ClassicPhrasePack: PhrasePack {
    let id = "classic-phrases"
    let displayName = "Classic"

    func phrases(for event: PhraseEventType) -> [String] {
        switch event {
        case .fifteen:      return ["15 for {points}!"]
        case .pair:         return ["Pair!"]
        case .threeOfAKind: return ["Three of a Kind!"]
        case .fourOfAKind:  return ["Four of a Kind!"]
        case .run:          return ["Run of {points}!"]
        case .flush:        return ["Flush!"]
        case .nobs:         return ["His Nobs!"]
        case .go:           return ["Go!"]
        case .thirtyOne:    return ["31 for 2!"]
        case .lastCard:     return ["Last Card!"]
        case .hisHeels:     return ["His Heels!"]
        case .bigHand:      return ["Big Hand!"]
        case .perfect29:    return ["Perfect 29!"]
        case .skunk:        return ["Skunked!"]
        case .doubleSkunk:  return ["Double Skunked!"]
        case .win:          return ["You Win!"]
        case .lose:         return ["You Lose"]
        case .closeGame:    return ["Close Game!"]
        }
    }
}

// MARK: - Grandpa Phrase Pack

/// Warm, folksy, family-game-night flavor.
struct GrandpaPhrasePack: PhrasePack {
    let id = "grandpa-phrases"
    let displayName = "Grandpa"

    func phrases(for event: PhraseEventType) -> [String] {
        switch event {
        case .fifteen:
            return ["Fifteen-two!", "Fifteen-four, and that ain't all!", "Count 'em up!"]
        case .pair:
            return ["A pair! Just like socks!", "Two of a kind!", "Double trouble!"]
        case .threeOfAKind:
            return ["Three of a kind! Well I'll be!", "A triple! Haven't seen that in a while!", "Three's company!"]
        case .fourOfAKind:
            return ["Four of a kind! Holy smokes!", "All four! What are the odds!", "A quadruple! Unbelievable!"]
        case .run:
            return ["A run of {points}! Keep 'em comin'!", "That's a nice little run!", "On a streak!"]
        case .flush:
            return ["A flush! All dressed up!", "Same suit, nice hand!", "Flush! Pretty as a picture!"]
        case .nobs:
            return ["His Nobs! That little Jack sure helps!", "Nobs! Every point counts!", "The right Jack!"]
        case .go:
            return ["Go! Your turn, kiddo!", "Can't go any higher!", "Go for it!"]
        case .thirtyOne:
            return ["Thirty-one! Right on the money!", "31! Couldn't be better!", "Hit the mark!"]
        case .lastCard:
            return ["Last card! That's one for the road!", "One more for good measure!", "And the last one!"]
        case .hisHeels:
            return ["His Heels! Lucky cut!", "Heels! What a start!", "Jack off the top!"]
        case .bigHand:
            return ["Now that's a hand! Wowee!", "Big hand! Save some for the rest of us!", "What a whopper!"]
        case .perfect29:
            return ["Twenty-nine! I don't believe it!", "A perfect hand! In all my years!", "29! Call the papers!"]
        case .skunk:
            return ["You got skunked, kiddo!", "Better luck next time, sport!", "That's a skunk! Phew!"]
        case .doubleSkunk:
            return ["Double skunked! Oh my stars!", "A double skunk! That's rough, kiddo!", "Two skunks! Mercy!"]
        case .win:
            return ["Well played, kiddo!", "That's how it's done!", "Winner winner, chicken dinner!"]
        case .lose:
            return ["You'll get 'em next time!", "Good game, sport!", "Almost had it!"]
        case .closeGame:
            return ["Down to the wire!", "What a nail-biter!", "Close one, kiddo!"]
        }
    }
}

// MARK: - Trash Talk Phrase Pack

/// Competitive, playful trash talk.
struct TrashTalkPhrasePack: PhrasePack {
    let id = "trash-talk-phrases"
    let displayName = "Trash Talk"

    func phrases(for event: PhraseEventType) -> [String] {
        switch event {
        case .fifteen:
            return ["Read 'em and weep!", "Too easy!", "Cha-ching!"]
        case .pair:
            return ["Seeing double?", "Déjà vu!", "Another one!"]
        case .threeOfAKind:
            return ["Triple threat!", "Three's a charm!", "Hat trick!"]
        case .fourOfAKind:
            return ["Quad damage!", "Four of a kind, baby!", "Jackpot!"]
        case .run:
            return ["Can't stop, won't stop!", "On a roll!", "Run it up!"]
        case .flush:
            return ["Flush! All day!", "Suited and booted!", "Color me winning!"]
        case .nobs:
            return ["Nobs! Thank you very much!", "I'll take that point!", "Easy money!"]
        case .go:
            return ["Go! Can't keep up?", "Stuck already?", "Moving on!"]
        case .thirtyOne:
            return ["31! Boom!", "Nailed it!", "Right on target!"]
        case .lastCard:
            return ["Last card! Mine!", "I'll take that!", "Don't mind if I do!"]
        case .hisHeels:
            return ["Heels! Thanks for the free points!", "Lucky me!", "Off to a hot start!"]
        case .bigHand:
            return ["Massive hand! Deal with it!", "Try topping that!", "Get wrecked!"]
        case .perfect29:
            return ["TWENTY-NINE! Bow down!", "Perfect game! You're done!", "29! GG!"]
        case .skunk:
            return ["Skunked! How embarrassing!", "Did you even try?", "That's a wrap!"]
        case .doubleSkunk:
            return ["DOUBLE SKUNK! Brutal!", "Absolutely destroyed!", "Total domination!"]
        case .win:
            return ["Better luck next century!", "Is that all you've got?", "GG no re!"]
        case .lose:
            return ["I'll get you next time...", "This isn't over!", "Rematch. Now."]
        case .closeGame:
            return ["Too close for comfort!", "Had me sweating!", "That was intense!"]
        }
    }
}
