import SwiftUI

struct CardFanView: View {
    let cards: [Card]
    let selectedIndices: Set<Int>
    let selectable: Bool
    var hintIndices: Set<Int> = []
    var onTap: ((Int) -> Void)?
    var visibleCount: Int? = nil // If set, only show this many cards (for deal animation)
    var dealFromDeck: Bool = false // If true, animate cards from above (deck position)

    @Environment(\.cardScale) private var cardScale

    var body: some View {
        HStack(spacing: -8 * cardScale) {
            ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                let visible = visibleCount == nil || index < (visibleCount ?? 0)
                if visible {
                    DealtCardView(
                        card: card,
                        isSelected: selectedIndices.contains(index),
                        isHinted: hintIndices.contains(index),
                        dealIndex: index,
                        dealFromDeck: dealFromDeck
                    )
                    .zIndex(selectedIndices.contains(index) ? 10 : Double(index))
                    .onTapGesture {
                        if selectable {
                            HapticManager.selection()
                            onTap?(index)
                        }
                    }
                }
            }
        }
    }
}

/// Wraps CardView with a one-shot deal-in animation tied to card identity.
private struct DealtCardView: View {
    let card: Card
    let isSelected: Bool
    let isHinted: Bool
    let dealIndex: Int
    let dealFromDeck: Bool

    @State private var appeared = false
    @State private var hintPulse = false

    var body: some View {
        CardView(card: card, isSelected: isSelected)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(CribbageTheme.gold, lineWidth: isHinted ? 2.5 : 0)
                    .shadow(color: CribbageTheme.gold.opacity(hintPulse ? 0.8 : 0.3), radius: isHinted ? 8 : 0)
                    .opacity(isHinted ? 1 : 0)
            )
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : (dealFromDeck ? -200 : -30))
            .scaleEffect(appeared ? 1 : (dealFromDeck ? 0.6 : 0.85))
            .rotationEffect(appeared ? .zero : .degrees(dealFromDeck ? -10 : 0))
            .onAppear {
                withAnimation(.spring(duration: 0.4, bounce: 0.2).delay(dealFromDeck ? 0 : Double(dealIndex) * 0.08)) {
                    appeared = true
                }
            }
            .onChange(of: isHinted) {
                if isHinted {
                    withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                        hintPulse = true
                    }
                } else {
                    hintPulse = false
                }
            }
    }
}
