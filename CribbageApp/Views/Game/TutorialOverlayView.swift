import SwiftUI

// MARK: - Tutorial Steps

enum TutorialStep: Int, CaseIterable {
    case welcome
    case yourHand
    case selectDiscard
    case starterCard
    case playPhase
    case sayGo
    case counting
    case cribbageBoard
    case complete

    var title: String {
        switch self {
        case .welcome: return "Welcome to Cribbage!"
        case .yourHand: return "Your Hand"
        case .selectDiscard: return "Discard to the Crib"
        case .starterCard: return "The Starter Card"
        case .playPhase: return "The Play"
        case .sayGo: return "Saying Go"
        case .counting: return "Counting Points"
        case .cribbageBoard: return "The Board"
        case .complete: return "You're Ready!"
        }
    }

    var message: String {
        switch self {
        case .welcome:
            return "Let's learn the basics as you play your first game. Tap to continue through tips."
        case .yourHand:
            return "You've been dealt 6 cards. You'll keep 4 and send 2 to the crib."
        case .selectDiscard:
            return "Tap 2 cards to select them, then hit \"Send to Crib\". Keep cards that make pairs, runs, or add to 15."
        case .starterCard:
            return "A starter card is cut from the deck. It's shared by both players during counting."
        case .playPhase:
            return "Take turns playing cards. The running total counts toward 31. Score points for pairs, runs, and hitting 15 or 31."
        case .sayGo:
            return "If you can't play without exceeding 31, say \"Go\". Your opponent continues until they can't either."
        case .counting:
            return "After play, count your hand. Look for 15s, pairs, runs, flushes, and \"His Nobs\" (Jack of starter suit)."
        case .cribbageBoard:
            return "Track scores on the board. First to 121 wins! The dealer's crib is counted last."
        case .complete:
            return "You've got the basics! Check \"Rules\" in the menu for the full reference. Good luck!"
        }
    }

    var icon: String {
        switch self {
        case .welcome: return "hand.wave.fill"
        case .yourHand: return "rectangle.stack.fill"
        case .selectDiscard: return "arrow.right.circle.fill"
        case .starterCard: return "suit.diamond.fill"
        case .playPhase: return "play.fill"
        case .sayGo: return "hand.raised.fill"
        case .counting: return "number.circle.fill"
        case .cribbageBoard: return "chart.bar.fill"
        case .complete: return "checkmark.circle.fill"
        }
    }

    /// Which game phase triggers this step
    var triggerPhase: GamePhase? {
        switch self {
        case .welcome, .yourHand, .selectDiscard: return .discard
        case .starterCard: return nil // triggered after starter ceremony
        case .playPhase, .sayGo: return .play
        case .counting: return .countNonDealer
        case .cribbageBoard: return nil
        case .complete: return nil
        }
    }
}

// MARK: - Tutorial Overlay

struct TutorialOverlayView: View {
    let step: TutorialStep
    let onNext: () -> Void
    let onSkip: () -> Void

    @State private var appeared = false

    var body: some View {
        VStack {
            if step == .cribbageBoard || step == .starterCard {
                tooltipCard
                Spacer()
            } else {
                Spacer()
                tooltipCard
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.3).ignoresSafeArea())
        .onTapGesture { onNext() }
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.25)) {
                appeared = true
            }
        }
    }

    private var tooltipCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: step.icon)
                    .font(.title3)
                    .foregroundStyle(CribbageTheme.gold)
                Text(step.title)
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(CribbageTheme.ivory)
                Spacer()
                Button(action: onSkip) {
                    Text("Skip")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(CribbageTheme.ivory.opacity(0.6))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(CribbageTheme.feltGreenDark.opacity(0.8))
                                .strokeBorder(CribbageTheme.ivory.opacity(0.2), lineWidth: 1)
                        )
                }
            }

            Text(step.message)
                .font(.subheadline)
                .foregroundStyle(CribbageTheme.ivory.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                // Progress dots
                HStack(spacing: 4) {
                    ForEach(0..<TutorialStep.allCases.count, id: \.self) { i in
                        Circle()
                            .fill(i <= step.rawValue ? CribbageTheme.gold : CribbageTheme.ivory.opacity(0.3))
                            .frame(width: 5, height: 5)
                    }
                }

                Spacer()

                Text(step == .complete ? "Tap to finish" : "Tap to continue")
                    .font(.caption)
                    .foregroundStyle(CribbageTheme.gold.opacity(0.7))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(CribbageTheme.feltGreenDark.opacity(0.95))
                .strokeBorder(CribbageTheme.gold.opacity(0.4), lineWidth: 1)
                .shadow(color: .black.opacity(0.4), radius: 8, y: 4)
        )
        .offset(y: appeared ? 0 : 20)
    }
}
