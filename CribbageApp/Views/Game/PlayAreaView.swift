import SwiftUI

struct PlayAreaView: View {
    let playPile: [Card]
    let runningTotal: Int
    let starter: Card?

    var body: some View {
        VStack(spacing: 8) {
            // Starter card
            if let starter {
                HStack(spacing: 8) {
                    Text("Starter")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    CardView(card: starter, isSmall: true)
                }
            }

            // Play pile
            if !playPile.isEmpty {
                HStack(spacing: -8) {
                    ForEach(Array(playPile.enumerated()), id: \.element.id) { idx, card in
                        CardView(card: card, isSmall: true)
                            .zIndex(Double(idx))
                    }
                }
            }

            // Running total
            if runningTotal > 0 {
                Text("Count: \(runningTotal)")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: Capsule())
            }
        }
    }
}
