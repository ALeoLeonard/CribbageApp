import SwiftUI

// MARK: - Peg Theme Protocol

protocol PegTheme: Identifiable {
    var id: String { get }
    var displayName: String { get }
    var playerColor: Color { get }
    var opponentColor: Color { get }
    var playerGlowColor: Color { get }
    var opponentGlowColor: Color { get }
}
