import SwiftUI

struct CardFanView: View {
    let cards: [Card]
    let selectedIndices: Set<Int>
    let selectable: Bool
    var onTap: ((Int) -> Void)?

    var body: some View {
        HStack(spacing: -12) {
            ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                CardView(
                    card: card,
                    isSelected: selectedIndices.contains(index)
                )
                .zIndex(Double(index))
                .onTapGesture {
                    if selectable {
                        onTap?(index)
                    }
                }
            }
        }
    }
}
