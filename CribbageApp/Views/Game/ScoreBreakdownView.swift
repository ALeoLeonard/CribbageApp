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
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color.accentColor, lineWidth: 2)
                    )
            }

            // Score items
            if breakdown.items.isEmpty {
                Text("No points")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 4) {
                    ForEach(breakdown.items) { event in
                        HStack {
                            Text(event.reason)
                                .font(.subheadline)
                            Spacer()
                            Text("+\(event.points)")
                                .font(.subheadline.bold())
                        }
                    }
                }
            }

            Divider()

            HStack {
                Text("Total")
                    .font(.headline)
                Spacer()
                Text("\(breakdown.total)")
                    .font(.headline.bold())
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
