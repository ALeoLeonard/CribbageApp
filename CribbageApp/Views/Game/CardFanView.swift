import SwiftUI

struct CardFanView: View {
    let cards: [Card]
    let selectedIndices: Set<Int>
    let selectable: Bool
    var hintIndices: Set<Int> = []
    var onTap: ((Int) -> Void)?
    var onInvalidTap: ((Int) -> Void)?
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
                        selectable: selectable || onInvalidTap != nil,
                        dealIndex: index,
                        dealFromDeck: dealFromDeck,
                        onTap: {
                            if selectable {
                                HapticManager.selection()
                                onTap?(index)
                            } else if onInvalidTap != nil {
                                onInvalidTap?(index)
                            }
                        }
                    )
                    .zIndex(selectedIndices.contains(index) ? 10 : Double(index))
                }
            }
        }
    }
}

/// Wraps CardView with a one-shot deal-in animation tied to card identity.
struct DealtCardView: View {
    let card: Card
    let isSelected: Bool
    let isHinted: Bool
    var selectable: Bool = false
    let dealIndex: Int
    let dealFromDeck: Bool
    var onTap: (() -> Void)? = nil

    @State private var appeared = false
    @State private var hintPulse = false
    @State private var shakeOffset: CGFloat = 0
    @State private var pressed = false

    var body: some View {
        CardView(card: card, isSelected: isSelected)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(CribbageTheme.gold, lineWidth: isHinted ? 2.5 : 0)
                    .shadow(color: CribbageTheme.gold.opacity(hintPulse ? 0.8 : 0.3), radius: isHinted ? 8 : 0)
                    .opacity(isHinted ? 1 : 0)
            )
            .opacity(appeared ? 1 : 0)
            .offset(x: shakeOffset, y: appeared ? 0 : (dealFromDeck ? -200 : -30))
            .scaleEffect(appeared ? (pressed ? 0.92 : 1.0) : (dealFromDeck ? 0.6 : 0.85))
            .rotationEffect(appeared ? .zero : .degrees(dealFromDeck ? -10 : 0))
            .onTapGesture {
                guard selectable else { return }
                withAnimation(.spring(duration: 0.1)) { pressed = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(duration: 0.2, bounce: 0.4)) { pressed = false }
                    onTap?()
                }
            }
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

    /// Trigger a brief horizontal shake animation (called externally).
    func shake() {
        withAnimation(.linear(duration: 0.06)) { shakeOffset = -6 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
            withAnimation(.linear(duration: 0.06)) { shakeOffset = 6 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.linear(duration: 0.06)) { shakeOffset = -4 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation(.spring(duration: 0.15)) { shakeOffset = 0 }
        }
    }
}
