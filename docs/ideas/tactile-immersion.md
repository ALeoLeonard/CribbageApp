---
id: idea-tactile-immersion
type: idea
title: "Tactile Immersion & Deep Customization System"
status: promoted
author: /idea
created: 2026-03-02
updated: 2026-03-02
refs: [idea-tactile-immersion-raw, epic-cosmetic-system, epic-progression-unlocks]
themes: ["cosmetic-architecture", "personality-phrases", "progression-unlocks", "sensory-packs"]
scope: "general"
---

# Tactile Immersion & Deep Customization — Refined Ideas

> Refined from [tactile-immersion-raw](./tactile-immersion-raw.md)

## Themes

Four themes emerged, ordered by architectural dependency:

1. **Cosmetic Architecture** — The system that makes everything else possible. A unified registry for all customizable slots (card fronts, backs, boards, pegs, sounds, haptics, phrases). Build once, fill forever.
2. **Personality & Phrases** — The emotional differentiator. Custom callout text per scoring event, character identity, nostalgia as a feature. This is why people share screenshots and tell friends.
3. **Progression & Unlocks** — The Duolingo loop. Condition-based unlock engine that watches stats and awards cosmetics. Makes every game feel like progress even when you lose.
4. **Sensory Packs** — Sound design, haptic signatures, and animation weight bundled into swappable packs. A "Jazz Lounge" pack feels completely different from "Classic Wood" — same game, different vibe.

## Current Architecture Assessment

The existing theme system (3 protocols: `CardBackTheme`, `TableTheme`, `BoardTheme`) is the right pattern but covers only 3 of ~10 customizable slots. Sound and haptics are hardcoded methods with no plugin system. Stats tracking is solid (16 metrics) but has no event/observer system for triggering unlocks.

| System | Current State | Needed State |
|--------|--------------|--------------|
| Visual themes | 3 protocols, good | Expand to cover card fronts, pegs, UI accents |
| Sound | 13 hardcoded methods | Protocol-based SoundPack with parameterized events |
| Haptics | 7 static methods | Protocol-based HapticPack with intensity scaling |
| Phrases/Callouts | Hardcoded strings + point-based color | Data-driven PhraseBank per scoring event |
| Unlocks | None (premium is binary) | Condition engine watching StatsManager |
| Character identity | Just playerName string | Persona struct: name, avatar, phrase pack, cosmetic loadout |

## Idea Cards

### 1. Cosmetic Slot Registry

**Problem/Opportunity**: Today, adding a new customizable category (e.g., "peg themes") requires a new protocol, new ThemeManager properties, new selection UI, and new persistence — ~200 lines of boilerplate per category. The theme system works but doesn't scale to 10+ customizable slots.

**Proposed Direction**: Create a `CosmeticSlot` enum that defines all customizable categories, and a `CosmeticItem` protocol that any content conforms to. A `CosmeticRegistry` holds all available items per slot, tracks which are unlocked, and which are equipped. The ThemeManager evolves into this registry rather than being replaced.

```
CosmeticSlot: cardBack, cardFront, table, board, peg, soundPack, hapticPack, phrasePack, avatar
CosmeticItem: id, slot, displayName, previewImage, isPremium, unlockCondition?
CosmeticRegistry: items(for slot:), equipped(for slot:), equip(item:), unlock(item:), isUnlocked(item:)
```

Adding a new mahogany board = one new struct conforming to `CosmeticItem`. No code changes to registry, UI, or persistence.

**Value Signal**: Developers (us) can ship new content packs with zero architectural work. Players get a growing catalog that feels alive.

**Open Questions**:
- Migrate existing 3 theme protocols into this system, or layer on top?
- How to handle "bundles" (buy the Jazz Pack → unlocks sound + board + card back together)?
- Where to store equipped selections — UserDefaults (current) or a single Codable struct?
- Should free users get 2-3 options per slot, or 1 default + everything locked?

**Relevance**: ThemeManager.swift (evolves into CosmeticRegistry), StoreManager.swift (premium gates), all views that read theme properties

**Size Gut-feel**: Large — foundational refactor, but pays for itself immediately by making every subsequent idea card smaller

---

### 2. Phrase Pack System ("That's better than a kick in the head!")

**Problem/Opportunity**: Scoring callouts are generic text ("Pair for 2", "Run of 3 for 3"). Cribbage is a game of table talk — every family has their own expressions. Generic text feels lifeless compared to the banter people remember from playing in person.

**Proposed Direction**: Create a `PhrasePack` protocol with methods returning strings for each scoring event type. The default pack returns current generic text. Custom packs return character-specific phrases. Users can eventually create their own packs (v2).

Event types to cover:
- **Scoring**: fifteen, pair, three-of-a-kind, run, flush, nobs, big hand (20+), perfect 29
- **Play phase**: go, thirty-one, last card
- **Game events**: skunk, double skunk, win, lose, close game
- **Reactions**: opponent scores big, opponent skunks you, comeback win

Example packs:
- **Classic Grandpa**: "Fifteen-two, fifteen-four, and the rest don't score!", "That's better than a kick in the head!", "You got skunked, kiddo!"
- **Trash Talk**: "Is that all you've got?", "Read 'em and weep!", "Better luck next century!"
- **Zen Master**: "A humble two points.", "The cards teach patience.", "Victory and defeat are the same river."

**Value Signal**: This is the feature people screenshot and share. "My cribbage app sounds like my grandpa" is a 5-star review and an organic referral.

**Open Questions**:
- How many phrases per event type? (3-5 random rotation feels natural)
- Should phrases appear as text callouts, speech bubbles from an avatar, or both?
- User-created phrase packs: in-app text editor, or import from file/share sheet?
- Localization: phrase packs are inherently English — is that okay for v1?
- Should opponent AI also use phrase packs? (e.g., Easy AI uses polite phrases, Hard AI uses competitive ones)

**Relevance**: ScoringCalloutView.swift, GameViewModel.swift (callout generation), new PhrasePack protocol + packs, CosmeticRegistry (slot: .phrasePack)

**Size Gut-feel**: Medium — protocol + 2-3 packs + UI for selection. User-created packs are a separate Large ticket.

---

### 3. Progression & Unlock Engine

**Problem/Opportunity**: Currently, content is either free or behind a single $4.99 paywall. There's no sense of earning or discovering things through play. Duolingo proves that progression systems drive daily engagement even in "solved" activities.

**Proposed Direction**: Create an `UnlockCondition` enum that encodes achievement-like rules, and an `UnlockManager` that observes StatsManager and fires unlock events when conditions are met.

```swift
enum UnlockCondition {
    case gamesPlayed(Int)          // Play 50 games → unlock Vintage card fronts
    case winsWithDifficulty(Difficulty, Int)  // Beat Hard AI 10 times → unlock Gold pegs
    case handScore(Int)            // Score a 24+ hand → unlock "Card Shark" phrase pack
    case winStreak(Int)            // 5 win streak → unlock Neon board
    case skunkDelivered(Int)       // Skunk 3 opponents → unlock Skull card back
    case mugginsCaught(Int)        // Catch 10 muggins → unlock "Eagle Eye" avatar
    case perfectCount(Int)         // Count perfectly 20 times → unlock Zen phrase pack
    case premium                   // IAP purchase → unlock all premium items
}
```

When an unlock triggers: celebratory animation + sound + "New item unlocked!" toast with preview. Items queue if multiple unlock simultaneously.

**Value Signal**: Every game, win or lose, moves you toward something. Players open the app to check what's close to unlocking, play "just one more" to hit a milestone.

**Open Questions**:
- How many unlockable items at launch? (20-30 feels right — enough to discover over weeks)
- Should there be a "collection" screen showing all items with locked silhouettes?
- XP/currency system, or purely condition-based? (Condition-based is simpler and more authentic to cribbage culture)
- Can premium IAP accelerate but not gate? (e.g., premium unlocks 10 items instantly, but all items are earnable through play)
- Notification for near-misses? ("2 more wins to unlock Mahogany Board!")

**Relevance**: StatsManager.swift (condition source), new UnlockManager.swift, new UnlockCondition enum, CosmeticRegistry (unlock tracking), GameViewModel (trigger check after each game)

**Size Gut-feel**: Medium — the engine itself is straightforward (check conditions against stats). The design work (which items, which conditions, what feels fair) is the real effort.

---

### 4. Sound Packs

**Problem/Opportunity**: SoundManager produces 13 distinct sounds via AVAudioEngine synthesis — all hardcoded as parameterized method calls. The sounds are good but monolithic. You can't have a "warm acoustic" game and a "crisp digital" game — it's one sound palette for everyone.

**Proposed Direction**: Create a `SoundPack` protocol mirroring the current 13 sound methods. The default pack uses the existing synthesized sounds. New packs can use different synthesis parameters, or eventually bundled audio files. The SoundManager becomes a dispatcher that delegates to the equipped pack.

```swift
protocol SoundPack {
    var id: String { get }
    var displayName: String { get }
    func playCardSlide()
    func playCardPlace()
    func playScore(points: Int)
    func playShuffle()
    func playDeal()
    func playWin()
    // ... etc
}
```

Example packs:
- **Classic** (current sounds): Crisp card slides, bright chimes
- **Jazz Lounge**: Muted card taps, saxophone riffs for big scores, brushed-snare shuffles
- **Retro Arcade**: 8-bit beeps, chiptune fanfares, pixel-style SFX
- **Quiet Evening**: Soft card whispers, gentle bell tones, minimal

**Value Signal**: Sound is 50% of "feel." A Jazz Lounge sound pack transforms the entire emotional experience without changing a single pixel.

**Open Questions**:
- Synthesis-only packs (no audio files, small app size) vs. bundled audio (richer, but increases bundle)?
- How many packs at launch? (3 feels right: Classic, one premium, one unlockable)
- Should sound packs auto-pair with visual themes, or be independently selectable?
- Volume/mix controls per category (card sounds vs. scoring fanfares)?

**Relevance**: SoundManager.swift (refactor to protocol dispatch), new SoundPack protocol + concrete packs, CosmeticRegistry (slot: .soundPack)

**Size Gut-feel**: Medium — protocol extraction from existing code is mechanical. New pack creation requires sound design iteration.

---

### 5. Haptic Packs

**Problem/Opportunity**: HapticManager has 7 static methods with hardcoded UIKit feedback generator calls. Like sound, haptics are monolithic — no way to have a "subtle" vs. "punchy" experience.

**Proposed Direction**: Create a `HapticPack` protocol with methods for each game event. Packs define intensity, pattern, and rhythm. Some players want every card to thump; others want minimal feedback.

Example packs:
- **Standard** (current): Medium impacts on scores, light on card plays
- **Intense**: Heavy impacts, multi-tap patterns for combos, sustained buzz for big hands
- **Subtle**: Selection feedback only on key moments, no card-play haptics
- **Off**: Exists as a pack (not just a toggle) so the system stays consistent

**Value Signal**: Accessibility and preference in one system. Older players may want subtle; younger players want the Hearthstone thump.

**Open Questions**:
- Is this worth a separate system, or should haptic intensity just be a slider (1-10)?
- Can custom haptic patterns be expressed as data (e.g., `[.heavy, .pause(0.1), .medium]`)?
- Should haptic packs pair with sound packs as a single "feel pack"?

**Relevance**: HapticManager.swift (refactor to protocol dispatch), CosmeticRegistry (slot: .hapticPack)

**Size Gut-feel**: Small — fewer events than sound, simpler implementation. Could ship as part of Sound Packs.

---

### 6. Card Front Themes

**Problem/Opportunity**: Card faces are currently a single hardcoded design in CardView. Every competitor looks the same — standard playing card faces. Custom card art is an untapped cosmetic category with high visual impact.

**Proposed Direction**: Create a `CardFrontTheme` protocol that controls how card faces render. This could range from simple (color palette swaps, font changes) to rich (fully illustrated court cards, artistic pip layouts).

Example themes:
- **Classic**: Current standard design
- **Vintage**: Aged paper, ornate pip designs, old-world court cards
- **Minimalist**: Clean sans-serif ranks, geometric pips, white space
- **Watercolor**: Hand-painted style faces, soft color bleeds
- **Dark Mode**: Inverted colors, glowing pips on dark cards

**Value Signal**: Cards are the most-viewed element in the app. Custom card faces are the most visible cosmetic — players notice immediately.

**Open Questions**:
- Rendered (programmatic, like current) vs. asset-based (image per card)?
- If rendered: how much can be parameterized? (Color palette, font, pip shape, border style)
- If asset-based: 52 images per theme × multiple themes = significant bundle size
- Court cards (J/Q/K): custom illustrations or stylized text?

**Relevance**: CardView.swift, new CardFrontTheme protocol, CosmeticRegistry (slot: .cardFront)

**Size Gut-feel**: Large — high visual design effort. Programmatic approach (parameterized rendering) could make this Medium with less art dependency.

---

### 7. Peg & Board Customization

**Problem/Opportunity**: BoardTheme already controls wood grain/color, but pegs are hardcoded colors (blue for player, red for opponent) in CribbageBoardView. The board + pegs are the most nostalgic visual element of cribbage — everyone remembers their family's board.

**Proposed Direction**: Extend BoardTheme to include peg appearance (color, material, shape) or create a separate PegTheme. Allow players to pick their peg independently of the board.

Example pegs: Brass, Ivory, Ruby, Jade, Crystal, Obsidian
Example boards: Cherry, Walnut, Maple, Driftwood, Slate, Leather

**Value Signal**: "That looks exactly like the board my grandfather had." Nostalgia trigger with high emotional value.

**Open Questions**:
- Separate PegTheme protocol, or extend BoardTheme with peg properties?
- Player and opponent pegs: independently customizable, or matched pair?
- Should boards have "wear" variants (new vs. well-loved patina)?

**Relevance**: CribbageBoardView.swift, BoardTheme protocol (extend), CosmeticRegistry (slots: .board, .peg)

**Size Gut-feel**: Small — mostly color/gradient parameters on existing rendering code

---

### 8. Character/Persona System

**Problem/Opportunity**: Player identity is currently just a name string in UserDefaults. There's no sense of "this is my cribbage character." Hearthstone proves that even a portrait + emote system creates attachment.

**Proposed Direction**: Create a `Persona` struct that bundles: display name, avatar (SF Symbol or illustrated), equipped phrase pack, favorite cosmetic loadout. This becomes the player's identity across Game Center, pass-and-play, and eventually multiplayer.

**Value Signal**: Players invest in their persona. Investment creates retention. "I've built my cribbage identity" is a switching cost competitors can't replicate.

**Open Questions**:
- Avatars: SF Symbols (free, scalable), illustrated portraits (premium, distinctive), or user photos?
- Should AI opponents also have personas with their own phrase packs?
- Persona shown where: game board, Game Center, share cards, pass-and-play hand-over screen?

**Relevance**: New Persona model, PlayerState (extend), GameCenterManager (avatar), HandOverView (persona display)

**Size Gut-feel**: Medium — model + persistence is small, but UI touchpoints are spread across many views

---

## Cross-cutting Observations

### Build Order (Architectural Dependencies)

```
1. CosmeticRegistry (Idea #1)     ← Foundation. Everything else plugs into this.
   │
   ├─ 2. Phrase Packs (#2)        ← Highest emotional ROI. Ship 2-3 packs.
   ├─ 3. Unlock Engine (#3)       ← Makes all cosmetics feel earned.
   ├─ 4. Sound Packs (#4)         ← Transforms "feel" dramatically.
   ├─ 5. Haptic Packs (#5)        ← Can bundle with Sound Packs.
   ├─ 6. Card Fronts (#6)         ← High visual impact, high design effort.
   ├─ 7. Pegs & Boards (#7)       ← Quick win, extends existing system.
   └─ 8. Persona (#8)             ← Ties everything together as identity.
```

### Key Architectural Principle

**"Content is data, not code."** Every new board, phrase pack, or sound theme should be a struct conforming to a protocol — added in one file, automatically available in the registry, selection UI, unlock system, and persistence. Zero changes to infrastructure code.

### Migration Strategy

The existing ThemeManager (3 protocols, 13 themes) doesn't need to be torn down. The CosmeticRegistry can wrap it, adding new slot types alongside the existing ones. Migrate incrementally: registry first, then add new slots one at a time. Existing users' theme selections carry over via UserDefaults key compatibility.

### Monetization Implications

This system redefines the premium offering:
- **Free tier**: 1-2 options per slot, all gameplay features
- **Premium ($4.99)**: Unlocks all current content + earnable unlocks
- **Future content packs** ($0.99-$1.99): Themed bundles (Jazz Pack, Vintage Pack) — new revenue stream without ads
- **Earned unlocks**: ~20-30 items unlockable through play, creating progression even for free users

### Risk: Over-Engineering

The registry system is the right investment. But shipping 8 content categories at once is scope creep. Recommended approach:
1. Build the CosmeticRegistry + UnlockEngine (Sprint 7-8)
2. Ship Phrase Packs + Peg customization as first content (low art dependency, high impact)
3. Measure: do players engage with customization? Which slots get the most attention?
4. Expand to Sound Packs, Card Fronts, Persona based on data
