# CribbageApp

A native SwiftUI iOS implementation of the classic card game Cribbage.

## Requirements

- iOS 17.0+
- Xcode 16.0+
- Swift 6.0

## Getting Started

1. Open `CribbageApp.xcodeproj` in Xcode
2. Select an iOS Simulator or device
3. Build and run (Cmd+R)

### Regenerating the Xcode Project

If you modify the project structure, regenerate using [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```bash
brew install xcodegen
xcodegen generate
```

## Running Tests

```bash
# In Xcode: Cmd+U
# Or via CLI:
xcodebuild test -project CribbageApp.xcodeproj -scheme CribbageApp \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Architecture

### Models
- **Card.swift** — `Suit`, `Rank`, and `Card` types
- **GameState.swift** — `GamePhase`, `ScoreEvent`, `LastAction`, `PlayerState`
- **AIDifficulty.swift** — Easy, Medium, Hard difficulty levels

### Engine
- **Deck.swift** — Deck creation, shuffling, dealing
- **Scoring.swift** — Hand scoring (15s, pairs, runs, flush, nobs) and play-phase scoring
- **PlayPhase.swift** — `canPlay` helper for pegging
- **GameEngine.swift** — `@Observable` state machine driving the entire game
- **AI/** — Three difficulty levels implementing `CribbageAI` protocol:
  - **EasyAI** — Random discards and plays
  - **MediumAI** — Samples starters to evaluate discards; strategic pegging
  - **HardAI** — Full expected-value calculation over all 46 starters; offense/defense play scoring

### Views
- **MainMenuView** — Player name, difficulty picker, play button
- **GameBoardView** — Main game screen with score bar, opponent area, play area, player hand
- **CardView** — Single card rendering (face up/down, selected state)
- **CardFanView** — Overlapping hand of cards with tap selection
- **PlayAreaView** — Pegging pile + starter + running total
- **ScoreBreakdownView** — Itemized score display during counting phases
- **ActionBarView** — Phase-appropriate action buttons
- **GameOverView** — Winner display with play again / main menu

### ViewModel
- **GameViewModel** — `@MainActor @Observable` wrapper around `GameEngine` with animation delays for computer turns

## Game Flow

1. **Discard** — Select 2 cards to send to the crib
2. **Play** — Take turns playing cards (pegging), trying to score 15s, pairs, runs, and 31s
3. **Count** — Score hands: non-dealer first, then dealer's hand, then dealer's crib
4. **Rotate** — Swap dealer and start next round
5. **Win** — First player to 121 points wins

## Ported From

This app is a native port of the [CSCI-E7 Cribbage Final](https://github.com/dcdz/CSCI-E7-Cribbage-Final) web application (React + FastAPI).
