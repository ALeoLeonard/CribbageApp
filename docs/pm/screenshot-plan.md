---
id: screenshot-plan
type: design
title: App Store Screenshot Plan
status: draft
author: /design
created: 2026-03-02
updated: 2026-03-02
refs: [backlog, store-listing]
---

# App Store Screenshot Plan

## Required Device Sizes

| Device | Display Size | Resolution | Required |
|--------|-------------|------------|----------|
| iPhone 15 Pro Max | 6.7" | 1290 × 2796 | Yes (primary) |
| iPhone 15 Pro | 6.1" | 1179 × 2556 | Yes |
| iPad Pro 12.9" (6th gen) | 12.9" | 2048 × 2732 | Yes (if supporting iPad) |

App Store allows up to 10 screenshots per device size. We'll prepare 8.

---

## Screenshot Compositions

### 1. Gameplay — Play Phase (Hero Shot)

**Purpose**: First impression. Show the core game in action.

**Content**:
- Mid-game board with scores around 60-45 (player ahead)
- 3 cards in hand, 2 cards in play pile
- Board with pegs clearly visible
- Default theme (Classic green felt)

**Caption**: "The classic card game, beautifully crafted"

---

### 2. Score Breakdown

**Purpose**: Show the satisfying scoring experience and card-highlighting animation.

**Content**:
- Score breakdown overlay visible
- Strong hand (e.g., 16+ points) with multiple scoring combinations
- Cards highlighted to show which contribute to each score
- Visible point tally

**Caption**: "Watch every point come to life"

---

### 3. AI Hint System

**Purpose**: Demonstrate the coaching/hint differentiator.

**Content**:
- Discard phase with 6 cards in hand
- Hint overlay showing recommended discard with score breakdown
- Hard AI badge visible

**Caption**: "Smart hints powered by expert AI"

---

### 4. Theme Customization

**Purpose**: Show the depth of customization and premium value.

**Content**:
- Theme picker view open
- Grid of card back options (mix of free and premium)
- One premium theme selected, showing preview
- Show variety of visual styles

**Caption**: "30 ways to make it yours"

---

### 5. Game Over Celebration

**Purpose**: Show the reward moment and win state.

**Content**:
- Victory screen with trophy/confetti
- Final score (e.g., 121 to 98)
- Win streak indicator visible
- Stats summary

**Caption**: "Track every win and streak"

---

### 6. Difficulty Selection / Main Menu

**Purpose**: Show brand identity and the 3 AI tiers.

**Content**:
- Main menu / new game screen
- Three difficulty options clearly labeled (Easy, Medium, Hard)
- Clean, inviting design
- App branding visible

**Caption**: "Three AI opponents, from casual to expert"

---

### 7. Stats & Game Center

**Purpose**: Show the depth of tracking and social competition.

**Content**:
- Stats screen with populated data (wins, losses, streaks, averages)
- Game Center achievements partially unlocked
- Leaderboard position visible

**Caption**: "Compete on Game Center leaderboards"

---

### 8. Interactive Tutorial

**Purpose**: Appeal to new players and show accessibility.

**Content**:
- Tutorial overlay on game board
- Tooltip pointing to a game element (e.g., "Tap a card to play it")
- Clear instructional text
- Progress indicator showing tutorial steps

**Caption**: "Learn to play in minutes"

---

## Capture Strategy

### Setup

1. **Create a demo game state** for each screenshot using a test harness or manual play
2. **Use Simulator** for pixel-perfect captures at exact resolutions
3. **Populate stats** with realistic data (e.g., 47 wins, 31 losses, 5-game streak)
4. **Unlock some premium items** to show variety in theme picker

### Visual Guidelines

- Use the default Classic theme for most shots (familiar, clean)
- Screenshot 4 (themes) should show the picker with multiple options
- Ensure the status bar shows a clean time (e.g., 9:41 AM — Apple standard)
- Hide any debug UI or developer indicators
- Use light mode for primary set; consider dark mode variants later

### Framing

- **No bezels** — App Store Connect accepts raw screenshots without device frames
- Add captions using App Store Connect's built-in text overlay feature, or prepare framed versions with Figma/Sketch
- Keep text large and readable at thumbnail size
- Use consistent caption font and positioning across all 8 screenshots

### Order Priority

Screenshots are displayed in order. Prioritize:
1. Hero gameplay shot (most important — shown in search results)
2. Score breakdown (satisfying, unique)
3. AI hints (differentiator)
4. Customization (premium value)
5. Game over (emotional payoff)
6. Menu (brand/difficulty)
7. Stats/Game Center (depth)
8. Tutorial (new player appeal)

---

## Checklist

- [ ] Capture all 8 compositions on 6.7" iPhone simulator
- [ ] Capture all 8 compositions on 6.1" iPhone simulator
- [ ] Capture all 8 compositions on 12.9" iPad simulator (if iPad supported)
- [ ] Add captions to each screenshot
- [ ] Review at thumbnail size for readability
- [ ] Upload to App Store Connect
