import SwiftUI

// MARK: - Muggins Hand View

/// Shows the hand cards during muggins claiming. Reveals score breakdown after claim.
struct MugginsHandView: View {
    let hand: [Card]
    let starter: Card?
    let result: MugginsResult?

    @State private var revealed = false

    var body: some View {
        VStack(spacing: 12) {
            // Show the hand + starter
            HStack(spacing: -8) {
                ForEach(hand) { card in
                    CardView(card: card, isSmall: true)
                }
                if let starter {
                    CardView(card: starter, isSmall: true)
                        .overlay(
                            RoundedRectangle(cornerRadius: CribbageTheme.cardCornerRadius)
                                .strokeBorder(CribbageTheme.gold, lineWidth: 2)
                        )
                }
            }

            if result == nil {
                // Counting prompt
                Text("Count your hand carefully...")
                    .font(.caption)
                    .foregroundStyle(CribbageTheme.ivory.opacity(0.5))
                    .italic()
            } else if let result {
                // Show muggins result summary
                if result.isPerfect {
                    Label("Perfect! \(result.actualScore) points", systemImage: "star.fill")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(CribbageTheme.gold)
                        .scorePop()
                } else if result.mugginsPoints > 0 {
                    VStack(spacing: 4) {
                        Text("Actual: \(result.actualScore) points")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(CribbageTheme.ivory)

                        Rectangle()
                            .fill(Color.red.opacity(0.4))
                            .frame(height: 1)

                        HStack {
                            Text("Muggins")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(.red)
                            Spacer()
                            Text("-\(result.mugginsPoints) to opponent")
                                .font(.subheadline.bold())
                                .foregroundStyle(.red)
                        }
                    }
                } else if result.overClaimed {
                    Text("Actual: \(result.actualScore) points")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(CribbageTheme.ivory)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(CribbageTheme.feltGreenDark.opacity(0.9))
                .strokeBorder(
                    (result?.mugginsPoints ?? 0) > 0
                        ? Color.red.opacity(0.5)
                        : CribbageTheme.gold.opacity(0.3),
                    lineWidth: 1
                )
        )
        .animation(.easeInOut(duration: 0.3), value: result?.actualScore)
    }
}

// MARK: - Score Breakdown View

struct ScoreBreakdownView: View {
    let breakdown: ScoreBreakdown

    var body: some View {
        VStack(spacing: 12) {
            // Show the hand + starter
            HStack(spacing: -8) {
                ForEach(breakdown.hand) { card in
                    CardView(card: card, isSmall: true)
                }
                CardView(card: breakdown.starter, isSmall: true)
                    .overlay(
                        RoundedRectangle(cornerRadius: CribbageTheme.cardCornerRadius)
                            .strokeBorder(CribbageTheme.gold, lineWidth: 2)
                    )
            }

            // Score items
            if breakdown.items.isEmpty {
                Text("No points")
                    .font(.subheadline)
                    .foregroundStyle(CribbageTheme.ivory.opacity(0.6))
            } else {
                VStack(spacing: 4) {
                    ForEach(Array(breakdown.items.enumerated()), id: \.element.id) { index, event in
                        HStack {
                            Text(event.reason)
                                .font(.subheadline)
                                .foregroundStyle(CribbageTheme.ivory)
                            Spacer()
                            Text("+\(event.points)")
                                .font(.subheadline.bold())
                                .foregroundStyle(CribbageTheme.gold)
                        }
                        .staggeredAppearance(index: index)
                    }
                }
            }

            // Divider
            Rectangle()
                .fill(CribbageTheme.gold.opacity(0.4))
                .frame(height: 1)

            HStack {
                Text("Total")
                    .font(.headline)
                    .foregroundStyle(CribbageTheme.ivory)
                Spacer()
                Text("\(breakdown.total)")
                    .font(.headline.bold())
                    .foregroundStyle(CribbageTheme.gold)
            }
            .scorePop()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(CribbageTheme.feltGreenDark.opacity(0.9))
                .strokeBorder(CribbageTheme.gold.opacity(0.3), lineWidth: 1)
        )
    }
}
