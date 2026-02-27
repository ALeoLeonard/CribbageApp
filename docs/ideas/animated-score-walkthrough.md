---
id: idea-animated-score-walkthrough
type: idea
title: "Animated Score Walkthrough During Hand Counting"
status: refined
author: /idea
created: 2026-02-27
updated: 2026-02-27
refs: [idea-animated-score-walkthrough-raw]
themes: ["visual-scoring", "learning-ux"]
scope: "counting-phase-ux"
---

# Animated Score Walkthrough — Refined Ideas

> Refined from [animated-score-walkthrough-raw](./animated-score-walkthrough-raw.md)

## Themes

Two themes emerged: **visual scoring** (making the abstract concrete) and **learning UX** (teaching through play). Both converge on the same feature — animate cards to show which ones form each scoring combination.

## Idea Cards

### 1. Visual Score Walkthrough

**Problem/Opportunity**: During counting phases, the score breakdown is a text list ("3 fifteens for 6", "Pair of 5s for 2"). Players — especially beginners — see the total but don't understand *which cards* make each combination. This is the #1 learning barrier in cribbage.

**Proposed Direction**: When the score breakdown appears, step through each scoring event sequentially:
1. Fan out the 4 hand cards + starter
2. For each ScoreEvent, lift/highlight the specific cards that form the combination (e.g., the 5 and 10 that make fifteen)
3. Show the score callout text alongside ("15 for 2!")
4. Cards settle back down, next combination lifts
5. After all combos shown, display the total

The animation pace could be ~1 second per combo with a slight overlap. A "Skip" tap or fast-forward could jump to the full breakdown for experienced players.

**Value Signal**: New players learn hand evaluation through visual demonstration every game, reducing the learning curve that makes cribbage intimidating.

**Open Questions**:
- Should this play automatically or require tap-to-advance (like a slideshow)?
- How to handle runs with multiplicity (e.g., "2x run of 3") — show each run variant separately or group?
- Should it only activate for the human's hand, or also show for the computer's hand (educational)?
- How to represent flush (all 4-5 cards) without it looking identical to "no highlight"?
- Performance: stepping through 7+ combos in a 29-hand — does the pacing feel tedious?

**Relevance**: Scoring.swift (needs to return card indices per event), ScoreBreakdownView.swift, GameBoardView.swift, CardFanView.swift, GameViewModel.swift

**Size Gut-feel**: Medium — Engine change is small (add `cards: [Card]` to ScoreEvent), but the animation choreography in SwiftUI is the real work.

---

### 2. Teaching Through Muggins

**Problem/Opportunity**: The animated walkthrough pairs naturally with muggins mode. Players who've just watched the computer demonstrate scoring combos will internalize patterns faster and count more accurately on their own turns.

**Proposed Direction**: When muggins is ON, show the walkthrough *after* the player submits their claim — as a reveal of what they missed (or got right). When muggins is OFF, show it during the normal counting flow. This creates a "learn → practice → test" loop.

**Value Signal**: Transforms muggins from a punitive mechanic into a learning tool — players *want* to turn it on because the walkthrough shows them what they missed.

**Open Questions**:
- Should the walkthrough highlight missed combos in red/orange vs found combos in gold?
- Could there be a "practice mode" that only does hand counting without a full game?

**Relevance**: MugginsResult, GameViewModel muggins flow, ScoreBreakdownView

**Size Gut-feel**: Small — mostly UI logic on top of idea #1

## Cross-cutting Observations

- **Engine change needed**: `ScoreEvent` must include which cards form the combination. Currently it only has `reason: String` and `points: Int`. Adding `cards: [Card]` (or card indices) is the foundational change everything else builds on.
- **Existing infrastructure**: The `ScoringCalloutView` pop animations and `DealtCardView` lift/offset mechanics can be reused. The card fan already supports per-card offset via `isSelected`.
- **Sequencing**: This idea should come after the current Sprint 3 work (scoring callouts, muggins) since it builds on both. Good candidate for Sprint 4-5 or the `epic-hand-analysis` post-MVP epic.
- **Settings control**: Should be toggleable ("Animate scoring walkthrough") — experienced players who already count in their head won't want to wait through the animation every round.
