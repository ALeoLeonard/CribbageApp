---
id: backlog
type: backlog
title: CribbageApp Project Backlog
status: draft
author: /pm
created: 2026-02-27
updated: 2026-02-27
refs: []
---

# CribbageApp Project Backlog

## SDLC Maturity Assessment

**Current Phase**: Late Alpha / Pre-Beta

The app has a production-quality game engine with complete cribbage rules, three AI difficulty tiers, polished UI with animations and sound, and persistent stats. However, it is missing table-stakes features (tutorial, skunk tracking, pass-and-play) that every top-rated competitor ships. Multiplayer is architecturally scaffolded but not connected. No monetization, analytics, or App Store preparation exists.

| Area | Maturity | Notes |
|------|----------|-------|
| Game Engine | Production | All rules, scoring, phases complete. 30+ unit tests. |
| AI | Production | 3 distinct strategies, well-tested. |
| UI/UX | Beta | Core views complete. Settings/ThemePicker partial. No tutorial. |
| Audio/Haptics | Production | Synthesized sounds, haptic feedback wired. |
| Statistics | Beta | Core stats tracked. Missing skunks, pegging averages. |
| Themes | Beta | 13 themes defined, unlock infrastructure exists. No purchase flow. |
| Multiplayer | Alpha | Models + ViewModel exist. No server, no WebSocket connection. |
| Monetization | Not Started | Theme premium flags exist but no StoreKit or ads. |
| Analytics | Not Started | No crash reporting, no event tracking. |
| App Store | Not Started | No screenshots, no listing, no review. |
| Accessibility | Not Started | No VoiceOver, Dynamic Type, or high-contrast support. |
| Tutorial | Not Started | No onboarding or learning flow. |

---

## MVP Definition (v1.0 - App Store Launch)

Ship a polished single-player cribbage game that can compete with Cribbage JD (4.8 stars) and Cribbage Classic (4.7 stars). Multiplayer deferred to v1.1.

**MVP must include:**
- Complete, polished single-player vs AI (already done)
- Tutorial / How-to-Play (table stakes -- every competitor has this)
- Skunk / double-skunk tracking (expected by cribbage players)
- Pass-and-play local multiplayer (standard feature)
- Muggins rule option (serious player expectation)
- Hint system powered by HardAI (competitive parity)
- Settings view completion (sound toggle, rules config)
- Theme picker wired to premium unlock
- StoreKit 2 premium purchase ($4.99 remove ads + unlock themes)
- Ad integration (interstitial between games, banner on menus)
- Game Center leaderboards + achievements
- iCloud sync for stats and purchases
- App Store screenshots, description, metadata
- Analytics + crash reporting (Firebase or TelemetryDeck)

---

## Active Epics

### epic-app-polish: Complete UI & Settings
Status: active | Tickets: 3/5
- [x] `ticket-complete-settings-view` [M] [p1-high] -- Wire up full settings (sound, haptics, rules, about)
- [ ] `ticket-wire-theme-picker` [M] [p1-high] -- Connect ThemePickerView to ThemeManager unlock flow
- [x] `ticket-enhanced-stats` [M] [p2-medium] -- Add skunk tracking, pegging averages, hand history
- [x] `ticket-card-sort-toggle` [S] [p2-medium] -- Sort hand by rank or suit option
- [ ] `ticket-icloud-sync` [M] [p1-high] -- Sync stats + theme unlocks via NSUbiquitousKeyValueStore

### epic-tutorial: Onboarding & Learning
Status: active | Tickets: 3/4
- [x] `ticket-first-launch-tutorial` [L] [p0-critical] -- Interactive guided first game with tooltip overlays
- [x] `ticket-how-to-play-screen` [M] [p1-high] -- Static rules reference accessible from menu
- [x] `ticket-hint-system` [M] [p1-high] -- Optional hints during discard/play powered by HardAI
- [ ] `ticket-scoring-practice` [M] [p2-medium] -- Practice mode to learn hand counting

### epic-game-rules: Missing Cribbage Rules & Modes
Status: active | Tickets: 3/4
- [x] `ticket-skunk-tracking` [S] [p1-high] -- Track skunk (31+ margin) and double-skunk (61+ margin)
- [x] `ticket-muggins-rule` [M] [p1-high] -- Optional muggins with manual counting mode
- [x] `ticket-pass-and-play` [L] [p1-high] -- Two-human local multiplayer with hand-over screen
- [ ] `ticket-customizable-rules` [S] [p2-medium] -- Settings toggles for muggins, free cut, nobs

### epic-monetization: StoreKit & Ads
Status: draft | Tickets: 0/5
- [ ] `ticket-storekit-manager` [L] [p0-critical] -- StoreKit 2 integration: premium IAP ($4.99), theme packs
- [ ] `ticket-ad-integration` [M] [p1-high] -- AdMob interstitial between games, banner on menu/stats
- [ ] `ticket-premium-gate` [M] [p1-high] -- Wire premium purchase to theme unlocks and ad removal
- [ ] `ticket-restore-purchases` [S] [p1-high] -- Restore purchases flow + receipt validation
- [ ] `ticket-paywall-ui` [M] [p1-high] -- Premium upsell screen with feature comparison

### epic-game-center: Apple Platform Integration
Status: draft | Tickets: 0/4
- [ ] `ticket-game-center-auth` [S] [p1-high] -- Game Center authentication on launch
- [ ] `ticket-leaderboards` [M] [p1-high] -- Submit scores: win streak, highest hand, win rate by difficulty
- [ ] `ticket-achievements` [L] [p2-medium] -- 12-15 achievements (29 hand, skunk, streak milestones)
- [ ] `ticket-share-results` [S] [p2-medium] -- Share game results as image to Messages/social

### epic-app-store-prep: Launch Readiness
Status: draft | Tickets: 0/5
- [ ] `ticket-analytics-setup` [M] [p1-high] -- Firebase Analytics / TelemetryDeck + crash reporting
- [ ] `ticket-app-icons` [M] [p1-high] -- App icon design (all required sizes)
- [ ] `ticket-screenshots` [M] [p1-high] -- App Store screenshots for iPhone + iPad
- [ ] `ticket-store-listing` [S] [p1-high] -- Title, subtitle, description, keywords, categories
- [ ] `ticket-privacy-policy` [S] [p1-high] -- Privacy policy page (required for App Store)

---

### epic-juice-polish: Duolingo-Style Sensory Polish
Status: active | Tickets: 3/5
- [x] `ticket-scoring-celebrations` [M] [p1-high] -- Escalating haptic combos, sparkle VFX, callout text for 15s/31/pairs/runs during pegging
- [x] `ticket-peg-animation` [M] [p1-high] -- Animate peg movement along cribbage board track on score change
- [ ] `ticket-score-anticipation` [M] [p2-medium] -- Tension build before starter reveal, drum-roll haptic for big hand counts
- [ ] `ticket-streak-celebrations` [S] [p2-medium] -- Progressive celebrations for win streaks (3/5/10), milestone haptic patterns
- [x] `ticket-micro-interactions` [M] [p2-medium] -- Card hover/press haptics, round transition fanfare, invalid play shake, combo escalation sound

## Post-MVP Epics

### epic-daily-challenges: Retention & Engagement (v1.1)
Status: draft | Tickets: 0/4
- [ ] `ticket-daily-hand-challenge` [L] [p2-medium] -- Daily preset hand for score optimization
- [ ] `ticket-daily-streak` [S] [p2-medium] -- Track consecutive days played with rewards
- [ ] `ticket-challenge-leaderboard` [M] [p2-medium] -- Global leaderboard for daily challenges
- [ ] `ticket-reward-system` [M] [p2-medium] -- Unlock themes/cosmetics via streaks and achievements

### epic-hand-analysis: Coaching & Analysis (v1.1)
Status: draft | Tickets: 0/3
- [ ] `ticket-discard-analyzer` [L] [p2-medium] -- Post-discard "optimal play" analysis using HardAI engine
- [ ] `ticket-pegging-review` [M] [p2-medium] -- Post-round pegging efficiency score
- [ ] `ticket-game-replay` [L] [p3-low] -- Save and replay completed games move-by-move

### epic-ai-personalities: Named AI Opponents (v1.2)
Status: draft | Tickets: 0/3
- [ ] `ticket-ai-character-system` [M] [p2-medium] -- Named opponents with avatars and play style descriptions
- [ ] `ticket-ai-commentary` [M] [p2-medium] -- Contextual remarks from AI during play
- [ ] `ticket-opponent-gallery` [M] [p3-low] -- Gallery to choose AI opponent in main menu

### epic-multiplayer: Online Play (v1.2+)
Status: draft | Tickets: 0/6
- [ ] `ticket-backend-server` [XL] [p2-medium] -- WebSocket game server (needs splitting)
- [ ] `ticket-user-auth` [L] [p2-medium] -- Sign in with Apple + guest mode
- [ ] `ticket-matchmaking` [L] [p2-medium] -- Online matchmaking with Elo rating
- [ ] `ticket-friend-system` [M] [p2-medium] -- Add friends, invite to game
- [ ] `ticket-reconnection` [M] [p2-medium] -- Handle disconnect/reconnect during online games
- [ ] `ticket-in-game-chat` [S] [p3-low] -- Quick reactions and text chat (model exists)

### epic-accessibility: Inclusive Design (v1.1)
Status: draft | Tickets: 0/4
- [ ] `ticket-voiceover-support` [L] [p2-medium] -- Full VoiceOver labels on all game elements
- [ ] `ticket-dynamic-type` [M] [p2-medium] -- Respect system text size preferences
- [ ] `ticket-high-contrast` [M] [p2-medium] -- High-contrast mode for card suits and board
- [ ] `ticket-colorblind-pegs` [S] [p2-medium] -- Alternative peg colors/shapes for colorblind users

### epic-widgets: iOS Platform Features (v1.2)
Status: draft | Tickets: 0/3
- [ ] `ticket-stats-widget` [M] [p3-low] -- Lock screen / home screen streak and stats widget
- [ ] `ticket-daily-challenge-widget` [M] [p3-low] -- Widget showing daily challenge prompt
- [ ] `ticket-live-activity` [L] [p3-low] -- Live Activity for in-progress games

---

## Dependency Graph

```
epic-app-polish ──────────────────┐
                                   ├──> epic-app-store-prep ──> LAUNCH v1.0
epic-tutorial ────────────────────┤
                                   │
epic-game-rules ──────────────────┤
                                   │
epic-monetization ────────────────┤
                                   │
epic-game-center ─────────────────┘

                           Post-MVP:
epic-daily-challenges ← (depends on: epic-game-center for leaderboards)
epic-hand-analysis    ← (no blockers, can start anytime post-launch)
epic-ai-personalities ← (no blockers)
epic-accessibility    ← (no blockers, can start anytime)
epic-multiplayer      ← (depends on: epic-monetization for subscription tier)
epic-widgets          ← (depends on: epic-daily-challenges for challenge widget)
```

### Critical Path (MVP)

```
ticket-complete-settings-view ──> ticket-wire-theme-picker ──> ticket-storekit-manager ──> ticket-premium-gate
                                                                       │
ticket-first-launch-tutorial (parallel) ───────────────────────────────┤
                                                                       │
ticket-skunk-tracking + ticket-muggins-rule (parallel) ────────────────┤
                                                                       │
ticket-pass-and-play (parallel) ───────────────────────────────────────┤
                                                                       │
ticket-game-center-auth ──> ticket-leaderboards + ticket-achievements ─┤
                                                                       │
ticket-analytics-setup (parallel) ─────────────────────────────────────┤
                                                                       ▼
                                               ticket-screenshots ──> ticket-store-listing ──> SUBMIT
```

### Ticket Dependencies (within MVP)

| Ticket | Blocked By | Blocks |
|--------|-----------|--------|
| ticket-complete-settings-view | -- | ticket-wire-theme-picker, ticket-customizable-rules |
| ticket-wire-theme-picker | ticket-complete-settings-view | ticket-premium-gate |
| ticket-storekit-manager | -- | ticket-premium-gate, ticket-restore-purchases, ticket-paywall-ui |
| ticket-premium-gate | ticket-storekit-manager, ticket-wire-theme-picker | ticket-ad-integration |
| ticket-ad-integration | ticket-premium-gate | -- |
| ticket-game-center-auth | -- | ticket-leaderboards, ticket-achievements |
| ticket-leaderboards | ticket-game-center-auth | -- |
| ticket-achievements | ticket-game-center-auth, ticket-skunk-tracking | -- |
| ticket-screenshots | all UI tickets | ticket-store-listing |
| ticket-store-listing | ticket-screenshots | SUBMIT |
| ticket-first-launch-tutorial | -- | -- |
| ticket-skunk-tracking | -- | ticket-achievements |
| ticket-pass-and-play | -- | -- |
| ticket-muggins-rule | -- | -- |
| ticket-hint-system | -- | -- |
| ticket-icloud-sync | ticket-storekit-manager | -- |

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| StoreKit 2 complexity (sandbox testing, edge cases) | Medium | High | Start early, test on device not simulator |
| App Store rejection (first submission) | Medium | Medium | Follow HIG, test all flows, prepare privacy manifest |
| Tutorial scope creep (interactive tutorial is complex) | High | Medium | Start with simple tooltip overlay, iterate |
| Ad SDK conflicts with SwiftUI lifecycle | Medium | Medium | Use AdMob SwiftUI wrappers, test thoroughly |
| Hard AI perceived as "cheating" by users | Medium | High | Add transparency (show AI "thinking"), tune difficulty |
| Pass-and-play hand security (peeking) | Low | Medium | Mandatory hand-over screen between turns |
| iCloud sync conflicts | Low | Medium | Use NSUbiquitousKeyValueStore (merge semantics built-in) |
| Premium pricing resistance ($4.99) | Medium | Medium | A/B test $3.99 vs $4.99, ensure free tier is generous |

---

## Recommended Sprint Sequence

### Sprint 1 (Week 1-2): Foundation Polish [DONE]
- [x] ticket-complete-settings-view [M]
- [x] ticket-skunk-tracking [S]
- [x] ticket-card-sort-toggle [S]
- [x] ticket-enhanced-stats [M]

### Sprint 2 (Week 3-4): Core Missing Features [DONE]
- [x] ticket-first-launch-tutorial [L]
- [x] ticket-hint-system [M]
- [x] ticket-pass-and-play [L]
- [x] ticket-how-to-play-screen [M]

### Sprint 3 (Week 5-6): Juice & Game Rules [DONE]
- [x] ticket-scoring-celebrations [M] -- Escalating haptics, sparkle VFX, callouts for pegging combos
- [x] ticket-peg-animation [M] -- Animate peg movement with spring physics and trail glow
- [x] ticket-muggins-rule [M] -- Optional muggins with manual counting and stepper UI
- [x] ticket-micro-interactions [M] -- Card press-down haptics, score glow, invalid play shake, round transition fanfare

### Sprint 4 (Week 7-8): Monetization Wiring & Game Center
- ticket-premium-gate [M]
- ticket-ad-integration [M]
- ticket-paywall-ui [M]
- ticket-leaderboards [M]
- ticket-restore-purchases [S]

### Sprint 5 (Week 9-10): Launch Prep
- ticket-achievements [L]
- ticket-icloud-sync [M]
- ticket-share-results [S]
- ticket-app-icons [M]
- ticket-privacy-policy [S]

### Sprint 6 (Week 11-12): Ship It
- ticket-screenshots [M]
- ticket-store-listing [S]
- ticket-customizable-rules [S]
- ticket-scoring-practice [M]
- Bug fixes, polish, TestFlight beta

**Total estimated MVP timeline: 10-12 weeks** (solo developer)

---

## Upcoming (Post-MVP)

| Version | Epic | Theme |
|---------|------|-------|
| v1.1 | epic-daily-challenges | Retention & engagement |
| v1.1 | epic-hand-analysis | Coaching (differentiator -- no competitor does this well) |
| v1.1 | epic-accessibility | Inclusive design (Apple promotes accessible apps) |
| v1.2 | epic-ai-personalities | Delight & differentiation |
| v1.2 | epic-widgets | Platform integration |
| v2.0 | epic-multiplayer | Online play (requires backend investment) |

---

## Handoff

**Artifact**: `docs/pm/backlog.md`

Suggested next steps:
- `/qa review docs/pm/backlog.md` -- ensure all requirements have tickets and acceptance criteria
- `/fe plan tutorial` -- design the interactive tutorial component architecture
- `/mobile plan pass-and-play` -- plan the two-human local multiplayer mode
- `/spec create monetization --from docs/pm/backlog.md` -- technical spec for StoreKit + ads
- `/design plan app-store-assets` -- design app icon, screenshots, and store listing visuals
