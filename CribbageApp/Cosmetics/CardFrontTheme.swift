import SwiftUI

// MARK: - Card Front Theme Protocol

protocol CardFrontTheme: Identifiable {
    var id: String { get }
    var displayName: String { get }
    var isPremium: Bool { get }

    // Background
    var backgroundGradient: LinearGradient { get }

    // Border
    var borderColor: Color { get }
    var borderWidth: CGFloat { get }

    // Suit colors — replaces hardcoded card.suit.color in CardView
    func suitColor(for suit: Suit) -> Color

    // Font weights
    var rankFontWeight: Font.Weight { get }
}

extension CardFrontTheme {
    var rankFontWeight: Font.Weight { .bold }
}
