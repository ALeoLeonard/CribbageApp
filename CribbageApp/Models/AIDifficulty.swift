import Foundation

enum AIDifficulty: String, CaseIterable, Identifiable {
    case easy
    case medium
    case hard

    var id: String { rawValue }

    var displayName: String { rawValue.capitalized }
}
