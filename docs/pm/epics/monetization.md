---
id: epic-monetization
type: epic
title: Monetization - StoreKit & Ads
status: draft
author: /pm
created: 2026-02-27
updated: 2026-02-27
refs: []
---

# Monetization - StoreKit & Ads

**Goal**: Implement a fair, consumer-friendly monetization system: generous free tier with ads, one-time premium purchase ($4.99) for ad removal + all themes, and individual theme packs.

**Success criteria**:
- StoreKit 2 handles non-consumable premium IAP and theme pack IAPs
- Interstitial ads appear between games (max 1 per 3 games) -- not during gameplay
- Banner ads on menu and stats screens (not game board)
- Premium purchase removes all ads and unlocks all themes
- Purchases restorable on new devices
- Paywall UI clearly shows free vs. premium comparison

## Tickets
- [ ] ticket-storekit-manager: StoreKit 2 product management and purchase flow
- [ ] ticket-ad-integration: AdMob interstitial + banner ads
- [ ] ticket-premium-gate: Wire premium purchase to theme unlocks + ad removal
- [ ] ticket-restore-purchases: Restore purchases flow
- [ ] ticket-paywall-ui: Premium upsell screen
