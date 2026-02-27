---
id: ticket-storekit-manager
type: ticket
title: StoreKit 2 Integration
status: draft
author: /pm
created: 2026-02-27
updated: 2026-02-27
refs: [epic-monetization]
epic: epic-monetization
estimate: L
priority: p0-critical
---

# StoreKit 2 Integration

**As a** player, **I want** to purchase premium features through the App Store, **so that** I can unlock themes and remove ads with a single purchase.

## Acceptance Criteria
- [ ] `StoreManager` class handles product loading, purchase, and entitlement verification using StoreKit 2
- [ ] Non-consumable IAP: "Premium Unlock" ($4.99) -- removes ads + unlocks all themes
- [ ] Optional individual theme packs ($0.99-$1.99 each) as non-consumable IAPs
- [ ] `StoreManager` exposes `isPremium: Bool` observable property
- [ ] Purchase status persists across app launches via Transaction.currentEntitlements
- [ ] StoreKit configuration file (.storekit) created for sandbox testing
- [ ] Handles all edge cases: deferred purchases, interrupted purchases, refunds
- [ ] Transaction listener observes updates throughout app lifecycle

## Technical Notes
- Use StoreKit 2 async API (Product, Transaction, not SKPaymentQueue)
- Create `StoreManager.swift` in Utilities/
- Add StoreKit capability to project.yml and Xcode project
- Create a `.storekit` configuration file for local testing
- Wire `isPremium` to ThemeManager.isUnlocked() checks

## Dependencies
- Blocked by: --
- Blocks: ticket-premium-gate, ticket-restore-purchases, ticket-paywall-ui, ticket-icloud-sync
