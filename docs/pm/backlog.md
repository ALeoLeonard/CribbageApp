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
| Game Engine | Production | All rules, scoring, phases complete. 73 unit tests. |
| AI | Production | 3 distinct strategies, well-tested. |
| UI/UX | Production | Full views, animations, card highlighting, themes. |
| Audio/Haptics | Production | SoundPack protocol (2 packs), HapticPack protocol (3 packs), fully customizable. |
| Statistics | Production | Full stats, skunk tracking, synced via iCloud KVS. |
| Themes/Cosmetics | Production | 13 themes + 3 card front themes + 3 phrase packs + 6 peg themes + 2 sound packs + 3 haptic packs wrapped in CosmeticRegistry. 9 customization slots defined. ThemeManager is typealias. |
| Monetization | Beta | StoreKit 2 IAP complete ($4.99 premium). Ads deferred. |
| Analytics | Production | TelemetryDeck integrated (guarded in DEBUG). |
| Game Center | Production | Auth, leaderboards, 13 achievements. |
| Accessibility | Production | VoiceOver labels on all game elements. |
| Tutorial | Production | Interactive guided tutorial + how-to-play screen. |
| App Store | In Progress | Privacy policy + manifest done, placeholder icon generated, TestFlight prep complete (code-signing config, archive script, export compliance). Missing: final icon art, screenshots, store listing, developer account approval. |
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
- [x] TestFlight preparation (privacy manifest, code-signing config, archive script, export compliance, placeholder icon)

**MVP remaining:**
- [ ] Apple Developer account approval
- [ ] App icon final artwork (replace placeholder)
- [ ] App Store screenshots (iPhone + iPad)
- [ ] App Store listing (title, subtitle, description, keywords)
- [ ] TelemetryDeck account setup (replace placeholder App ID)
- [ ] TestFlight beta build + invite testers
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
Status: active | 5/5 done (pending actual screenshot capture)
- [x] `ticket-analytics-setup` [M] [p1-high] — TelemetryDeck integrated
- [x] `ticket-privacy-policy` [S] [p1-high] — In-app PrivacyPolicyView
- [x] `ticket-testflight-prep` [M] [p1-high] — Privacy manifest, code-signing config, archive script, export compliance, placeholder icon
- [x] `ticket-screenshots` [M] [p1-high] — Screenshot plan documented (8 compositions, 3 device sizes). Capture pending.
- [x] `ticket-store-listing` [S] [p1-high] — Full listing drafted: name, subtitle (29 chars), description (1,893 chars), keywords (95 chars), categories, age rating

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

### PegTheme System
- [x] PegTheme protocol (player/opponent color + glow), 6 built-in peg themes (Classic, Brass free; Ivory, Ruby, Jade, Obsidian premium), CosmeticRegistry integration, CribbageBoardView decoupled from BoardTheme peg colors, 17 new tests

### SoundPack System
- [x] SoundSynth + SoundPack protocols (17 sound methods), 2 built-in packs (Classic free, Quiet Evening premium), SoundManager refactored to delegate to active pack, CosmeticRegistry integration, 14 new tests

### HapticPack System
- [x] HapticPack protocol (10 haptic methods), 3 built-in packs (Standard free, Subtle free, Intense premium), HapticManager refactored to delegate to active pack, CosmeticRegistry integration, 15 new tests

### CardFrontTheme System
- [x] CardFrontTheme protocol (backgroundGradient, borderColor/Width, suitColor, rankFontWeight), 3 built-in themes (Standard free, Modern free, Vintage premium), CardView refactored to use active theme, CosmeticRegistry integration, 17 new tests

### Pre-Launch Polish
- [x] App Store listing copy drafted (`docs/pm/store-listing.md`): name, subtitle, description, keywords, categories, age rating
- [x] Screenshot plan documented (`docs/pm/screenshot-plan.md`): 8 compositions, 3 device sizes, capture strategy
- [x] Replaced `print()` with `os.Logger` in GameCenterManager (4 calls → structured logging)
- [x] Removed force unwrap in Scoring.swift (`playPile.last!` → safe optional binding)

---

## Remaining Work to Ship v1.0

### TestFlight Preparation
- [x] PrivacyInfo.xcprivacy (UserDefaults CA92.1, no tracking)
- [x] Config/Local.xcconfig.template + gitignored Local.xcconfig for DEVELOPMENT_TEAM
- [x] Config/ExportOptions.plist for App Store Connect export
- [x] scripts/archive_and_upload.sh with Team ID guard + optional --upload
- [x] scripts/generate_app_icon.py → 1024x1024 placeholder icon generated
- [x] project.yml: configFiles block + ITSAppUsesNonExemptEncryption=false
- [x] CI workflow: create Local.xcconfig before xcodegen
- [x] .gitignore: Local.xcconfig, build/, *.xcarchive

### Sprint 7: App Store Submission
- [ ] Apple Developer account approval (pending)
- [ ] Fill in DEVELOPMENT_TEAM in Config/Local.xcconfig
- [ ] Replace placeholder app icon with final artwork
- [x] `ticket-screenshots` — Screenshot plan documented (8 compositions, 3 device sizes). Capture pending.
- [x] `ticket-store-listing` — Full listing drafted in `docs/pm/store-listing.md`
- [ ] TelemetryDeck account creation + real App ID
- [ ] TestFlight beta build + invite testers
- [x] Pre-launch bug fixes: print→Logger (GameCenterManager), force unwrap removal (Scoring.swift)
- [ ] App Store submission

---

## Post-MVP Epics

### v1.1: Deep Customization & Progression (NEW — from idea-tactile-immersion)

#### epic-cosmetic-system: Cosmetic System & Deep Customization
Status: active | 2 remaining | Ref: [idea-tactile-immersion](../ideas/tactile-immersion.md)
- [x] `ticket-cosmetic-registry` [L] [p0-critical] — CosmeticSlot enum, CosmeticItem protocol, unified registry ✅
- [x] `ticket-phrase-packs` [M] [p1-high] — PhrasePack protocol + 3 packs (Classic, Grandpa, Trash Talk) ✅
- [x] `ticket-peg-themes` [S] [p1-high] — PegTheme protocol + 6 peg styles (2 free, 4 premium) ✅
- [x] `ticket-sound-packs` [M] [p2-medium] — SoundPack protocol, refactor SoundManager, 2 packs (Classic free, Quiet Evening premium) ✅
- [x] `ticket-haptic-packs` [S] [p2-medium] — HapticPack protocol + 3 packs (Standard, Subtle, Intense), HapticManager delegates to active pack ✅
- [x] `ticket-card-front-themes` [L] [p2-medium] — CardFrontTheme protocol, CardView refactor, 3 styles (Standard free, Modern free, Vintage premium) ✅
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
| Apple Developer account pending | Medium | High | All prep done; blocked on approval for signing, TestFlight, App Store Connect |
| TelemetryDeck placeholder still in code | Low | High | Must create account and replace before release build |

---

## Dependency Graph (Updated)

```
DONE ──────────────────────────────┐
  epic-app-polish (complete)        │
  epic-tutorial (complete)          │
  epic-game-rules (complete)        ├──> epic-app-store-prep ──> LAUNCH v1.0
  epic-monetization (IAP done)      │      (2 tickets remaining)
  epic-game-center (complete)       │
  epic-juice-polish (complete)      │
  Sprint 6 polish (complete)        │
  TestFlight prep (complete)       ─┘

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
- `/design plan app-icon` — design final 1024x1024 app icon (replace placeholder)
- `/design plan screenshots` — plan App Store screenshot compositions
- `/copy write store-listing` — draft App Store title, subtitle, description, keywords
- Fill in `Config/Local.xcconfig` with real Team ID once developer account is approved
- `./scripts/archive_and_upload.sh --upload` to push first TestFlight build
