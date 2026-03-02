---
id: backlog
type: backlog
title: CribbageApp Project Backlog
status: active
author: /pm
created: 2026-02-27
updated: 2026-03-02
refs: []
---

# CribbageApp Project Backlog

## SDLC Maturity Assessment

**Current Phase**: Beta / Pre-Launch

Sprints 1-6 are complete. The app has a production-quality game engine, three AI tiers, polished UI with animations/sound/haptics, tutorial, pass-and-play, muggins, hint system, StoreKit 2 IAP, Game Center leaderboards + achievements, iCloud sync, TelemetryDeck analytics, VoiceOver accessibility, score breakdown with card-highlighting animation, in-app privacy policy, and release build optimizations. The CosmeticRegistry foundation layer is complete, enabling scalable deep customization for v1.1. Ad monetization is deferred until post-launch to focus on game quality first.

| Area | Maturity | Notes |
|------|----------|-------|
| Game Engine | Production | All rules, scoring, phases complete. 96 unit tests. |
| AI | Production | 3 distinct strategies, well-tested. |
| UI/UX | Production | Full views, animations, card highlighting, themes. |
| Audio/Haptics | Production | Synthesized sounds, haptic feedback wired. |
| Statistics | Production | Full stats, skunk tracking, synced via iCloud KVS. |
| Themes/Cosmetics | Production | 13 themes + 3 phrase packs wrapped in CosmeticRegistry. 9 customization slots defined. ThemeManager is typealias. |
| Monetization | Beta | StoreKit 2 IAP complete ($4.99 premium). Ads deferred. |
| Analytics | Production | TelemetryDeck integrated (guarded in DEBUG). |
| Game Center | Production | Auth, leaderboards, 13 achievements. |
| Accessibility | Production | VoiceOver labels on all game elements. |
| Tutorial | Production | Interactive guided tutorial + how-to-play screen. |
| App Store | In Progress | Privacy policy done, app icon catalog scaffolded. Missing: icon art, screenshots, store listing. |
| Multiplayer | Alpha | Models + ViewModel scaffolded. No server. Deferred to v2.0. |

---

## MVP Definition (v1.0 - App Store Launch)

Ship a polished single-player cribbage game that competes with Cribbage JD (4.8 stars) and Cribbage Classic (4.7 stars). Multiplayer and ads deferred.

**MVP complete:**
- [x] Complete single-player vs AI (3 difficulty tiers)
- [x] Tutorial / How-to-Play
- [x] Skunk / double-skunk tracking
- [x] Pass-and-play local multiplayer
- [x] Muggins rule option
- [x] Hint system powered by HardAI
- [x] Full settings (sound, haptics, rules config)
- [x] Theme picker wired to premium unlock
- [x] StoreKit 2 premium purchase ($4.99 unlock themes)
- [x] Game Center leaderboards + 13 achievements
- [x] iCloud sync for stats
- [x] TelemetryDeck analytics
- [x] VoiceOver accessibility
- [x] Score breakdown with card-highlighting animation
- [x] In-app privacy policy
- [x] Release build optimizations
- [x] App icon asset catalog structure

**MVP remaining:**
- [ ] App icon artwork (1024x1024 PNG)
- [ ] App Store screenshots (iPhone + iPad)
- [ ] App Store listing (title, subtitle, description, keywords)
- [ ] TelemetryDeck account setup (replace placeholder App ID)
- [ ] TestFlight beta testing
- [ ] Final bug fixes and polish

---

## Active Epics

### epic-app-polish: Complete UI & Settings — DONE
Status: complete | All tickets done
- [x] `ticket-complete-settings-view` [M] [p1-high]
- [x] `ticket-wire-theme-picker` [M] [p1-high] — Wired via StoreKit 2 premium gate
- [x] `ticket-enhanced-stats` [M] [p2-medium]
- [x] `ticket-card-sort-toggle` [S] [p2-medium]
- [x] `ticket-icloud-sync` [M] [p1-high]

### epic-tutorial: Onboarding & Learning — DONE (MVP scope)
Status: complete (MVP) | 1 post-MVP ticket remains
- [x] `ticket-first-launch-tutorial` [L] [p0-critical]
- [x] `ticket-how-to-play-screen` [M] [p1-high]
- [x] `ticket-hint-system` [M] [p1-high]
- [ ] `ticket-scoring-practice` [M] [p2-medium] — Deferred to v1.1

### epic-game-rules: Cribbage Rules & Modes — DONE
Status: complete | All tickets done
- [x] `ticket-skunk-tracking` [S] [p1-high]
- [x] `ticket-muggins-rule` [M] [p1-high]
- [x] `ticket-pass-and-play` [L] [p1-high]
- [x] `ticket-customizable-rules` [S] [p2-medium] — Nobs, his heels toggles in settings

### epic-monetization: StoreKit & Ads — PARTIAL
Status: active | IAP done, ads deferred
- [x] `ticket-storekit-manager` [L] [p0-critical] — StoreKit 2 integration complete
- [x] `ticket-premium-gate` [M] [p1-high] — Premium unlocks themes, removes ad placeholder
- [x] `ticket-restore-purchases` [S] [p1-high] — Restore flow in settings
- [x] `ticket-paywall-ui` [M] [p1-high] — Paywall view with feature comparison
- [ ] `ticket-ad-integration` [M] [p2-medium] — AdMob deferred to post-launch. AdManager placeholder exists.

### epic-game-center: Apple Platform Integration — DONE (MVP scope)
Status: complete (MVP) | 1 post-MVP ticket remains
- [x] `ticket-game-center-auth` [S] [p1-high]
- [x] `ticket-leaderboards` [M] [p1-high]
- [x] `ticket-achievements` [L] [p2-medium] — 13 achievements
- [ ] `ticket-share-results` [S] [p2-medium] — Deferred to v1.1

### epic-juice-polish: Sensory Polish — DONE
Status: complete | All tickets done
- [x] `ticket-scoring-celebrations` [M] [p1-high]
- [x] `ticket-peg-animation` [M] [p1-high]
- [x] `ticket-score-anticipation` [M] [p2-medium]
- [x] `ticket-streak-celebrations` [S] [p2-medium]
- [x] `ticket-micro-interactions` [M] [p2-medium]

### epic-app-store-prep: Launch Readiness — IN PROGRESS
Status: active | 2/5 done
- [x] `ticket-analytics-setup` [M] [p1-high] — TelemetryDeck integrated
- [x] `ticket-privacy-policy` [S] [p1-high] — In-app PrivacyPolicyView
- [ ] `ticket-app-icons` [M] [p1-high] — Asset catalog scaffolded, needs 1024x1024 artwork
- [ ] `ticket-screenshots` [M] [p1-high] — App Store screenshots for iPhone + iPad
- [ ] `ticket-store-listing` [S] [p1-high] — Title, subtitle, description, keywords

---

## Completed Sprint History

### Sprint 1-2: Foundation Polish + Core Features
- [x] Settings polish, skunk tracking, stats, how-to-play, hints, pass-and-play, tutorial

### Sprint 3: Juice & Game Rules
- [x] Scoring celebrations, muggins rule, peg animation, micro-interactions

### Sprint 4: Monetization & Game Center
- [x] StoreKit 2 IAP, paywall, Game Center leaderboards, ad hooks

### Sprint 5: Platform Integration
- [x] 13 achievements, iCloud KVS sync, TelemetryDeck analytics, VoiceOver accessibility

### Sprint 6: Score Animation & App Store Prep
- [x] Score breakdown card-highlighting animation, in-app privacy policy, app icon asset catalog, release build config, AnalyticsManager DEBUG guard, settings rate/privacy fixes

### CosmeticRegistry: Deep Customization Foundation
- [x] CosmeticSlot enum (9 slots), CosmeticItem protocol, theme wrappers, CosmeticRegistry class, ThemeManager typealias, 19 new tests

### PhrasePack System
- [x] PhrasePack protocol + PhraseEventType enum (18 event types), 3 built-in packs (Classic, Grandpa, Trash Talk), CosmeticRegistry integration, GameViewModel callout text driven by active phrase pack, 23 new tests

---

## Remaining Work to Ship v1.0

### Sprint 7: App Store Submission
- [ ] `ticket-app-icons` — Design and export 1024x1024 app icon
- [ ] `ticket-screenshots` — Capture App Store screenshots (iPhone 6.7", 6.1", iPad 12.9")
- [ ] `ticket-store-listing` — Write title, subtitle, description, keywords, categories
- [ ] TelemetryDeck account creation + real App ID
- [ ] TestFlight beta build + invite testers
- [ ] Final bug sweep and polish
- [ ] App Store submission

---

## Post-MVP Epics

### v1.1: Deep Customization & Progression (NEW — from idea-tactile-immersion)

#### epic-cosmetic-system: Cosmetic System & Deep Customization
Status: active | 6 remaining | Ref: [idea-tactile-immersion](../ideas/tactile-immersion.md)
- [x] `ticket-cosmetic-registry` [L] [p0-critical] — CosmeticSlot enum, CosmeticItem protocol, unified registry ✅
- [x] `ticket-phrase-packs` [M] [p1-high] — PhrasePack protocol + 3 packs (Classic, Grandpa, Trash Talk) ✅
- [ ] `ticket-peg-themes` [S] [p1-high] — PegTheme protocol + 6 peg styles
- [ ] `ticket-sound-packs` [M] [p2-medium] — SoundPack protocol, refactor SoundManager, 2 packs
- [ ] `ticket-haptic-packs` [S] [p2-medium] — HapticPack protocol, bundle with sound packs
- [ ] `ticket-card-front-themes` [L] [p2-medium] — CardFrontTheme protocol, parameterized rendering, 3 styles
- [ ] `ticket-cosmetic-picker-ui` [M] [p1-high] — Generic picker view for any CosmeticSlot
- [ ] `ticket-persona-system` [M] [p2-medium] — Persona struct: name, avatar, phrase pack, loadout

#### epic-progression-unlocks: Progression & Unlock Engine
Status: draft | 5 tickets | Ref: [idea-tactile-immersion](../ideas/tactile-immersion.md)
- [ ] `ticket-unlock-engine` [M] [p1-high] — UnlockCondition enum, UnlockManager observing StatsManager
- [ ] `ticket-unlock-celebration` [S] [p1-high] — Unlock animation + toast notification + queue
- [ ] `ticket-collection-screen` [M] [p2-medium] — Grid view of all items with locked/unlocked/equipped state
- [ ] `ticket-unlock-content-design` [M] [p1-high] — Define 20-30 items with conditions and thresholds
- [ ] `ticket-near-miss-prompts` [S] [p2-medium] — Post-game "X more to unlock Y" nudges

### v1.1: Engagement & Polish
| Epic | Theme | Key Tickets |
|------|-------|-------------|
| epic-daily-challenges | Retention | Daily hand challenge, streak tracking, leaderboard |
| epic-hand-analysis | Coaching (differentiator) | Discard analyzer, pegging review, game replay |
| epic-accessibility-v2 | Inclusive design | Dynamic Type, high-contrast, colorblind pegs |
| Remaining MVP tickets | Completeness | scoring-practice, share-results, ad-integration |

### v1.2: Differentiation
| Epic | Theme | Key Tickets |
|------|-------|-------------|
| epic-ai-personalities | Delight | Named opponents, AI commentary, opponent gallery |
| epic-widgets | Platform | Stats widget, daily challenge widget, Live Activity |

### v2.0: Online Play
| Epic | Theme | Key Tickets |
|------|-------|-------------|
| epic-multiplayer | Social | WebSocket server, auth, matchmaking, friends, chat |

---

## Risk Assessment (Updated)

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| App Store rejection (first submission) | Medium | Medium | Follow HIG, test all flows, privacy policy in-app |
| Hard AI perceived as "cheating" by users | Medium | High | Add transparency, tune difficulty |
| Premium pricing resistance ($4.99) | Medium | Medium | Free tier is fully playable, premium is cosmetic |
| Missing ads reduces revenue at launch | Low | Medium | Acceptable — focus on ratings first, add ads in v1.1 if needed |
| TelemetryDeck placeholder still in code | Low | High | Must create account and replace before release build |

---

## Dependency Graph (Updated)

```
DONE ──────────────────────────────┐
  epic-app-polish (complete)        │
  epic-tutorial (complete)          │
  epic-game-rules (complete)        ├──> epic-app-store-prep ──> LAUNCH v1.0
  epic-monetization (IAP done)      │      (3 tickets remaining)
  epic-game-center (complete)       │
  epic-juice-polish (complete)      │
  Sprint 6 polish (complete)       ─┘

                    Post-MVP v1.1 (Customization — priority):
ticket-cosmetic-registry (DONE) ──┐
  │                                ├──> epic-cosmetic-system (phrase packs, pegs, sounds, personas)
  └──> ticket-unlock-engine ───────┤
                                   └──> epic-progression-unlocks (celebrations, collection, nudges)

                    Post-MVP v1.1 (Engagement):
epic-daily-challenges ← (depends on: Game Center leaderboards — done)
epic-hand-analysis    ← (no blockers, can start anytime)
epic-ai-personalities ← (subsumes into persona system from epic-cosmetic-system)
epic-accessibility-v2 ← (VoiceOver done, extends with Dynamic Type etc.)

                    Post-MVP v1.2+:
epic-multiplayer      ← (requires backend investment)
epic-widgets          ← (depends on: epic-daily-challenges for challenge widget)
```

---

## Handoff

**Artifact**: `docs/pm/backlog.md`

Suggested next steps:
- `/design plan app-icon` — design the 1024x1024 app icon
- `/design plan screenshots` — plan App Store screenshot compositions
- `/copy write store-listing` — draft App Store title, subtitle, description, keywords
- `/qa plan beta-test` — create TestFlight beta test plan
