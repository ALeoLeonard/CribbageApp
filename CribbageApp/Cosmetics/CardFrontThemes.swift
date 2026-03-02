import SwiftUI

// MARK: - Standard Card Front

struct StandardCardFront: CardFrontTheme {
    let id = "standard"
    let displayName = "Standard"
    let isPremium = false

    var backgroundGradient: LinearGradient {
        CribbageTheme.cardFaceGradient
    }

    let borderColor = CribbageTheme.cardBorder
    let borderWidth: CGFloat = 0.8

    func suitColor(for suit: Suit) -> Color {
        switch suit {
        case .hearts, .diamonds: CribbageTheme.suitRed
        case .clubs, .spades: CribbageTheme.suitBlack
        }
    }
}

// MARK: - Modern Card Front

struct ModernCardFront: CardFrontTheme {
    let id = "modern-card"
    let displayName = "Modern"
    let isPremium = false

    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [.white, .white],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    let borderColor = Color(.systemGray4)
    let borderWidth: CGFloat = 0.5

    func suitColor(for suit: Suit) -> Color {
        switch suit {
        case .hearts, .diamonds: Color(red: 0.70, green: 0.18, blue: 0.18)
        case .clubs, .spades: Color(red: 0.22, green: 0.22, blue: 0.25)
        }
    }

    let rankFontWeight: Font.Weight = .semibold
}

// MARK: - Vintage Card Front

struct VintageCardFront: CardFrontTheme {
    let id = "vintage-card"
    let displayName = "Vintage"
    let isPremium = true

    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.96, green: 0.93, blue: 0.85),
                Color(red: 0.91, green: 0.87, blue: 0.78)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    let borderColor = Color(red: 0.62, green: 0.55, blue: 0.42)
    let borderWidth: CGFloat = 1.0

    func suitColor(for suit: Suit) -> Color {
        switch suit {
        case .hearts, .diamonds: Color(red: 0.55, green: 0.08, blue: 0.08)
        case .clubs, .spades: Color(red: 0.10, green: 0.10, blue: 0.08)
        }
    }
}
