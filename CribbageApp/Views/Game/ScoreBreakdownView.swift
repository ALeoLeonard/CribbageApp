import SwiftUI

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
