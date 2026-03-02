import Foundation

// MARK: - Phrase Event Type

enum PhraseEventType: String, CaseIterable, Sendable {
    case fifteen
    case pair
    case threeOfAKind
    case fourOfAKind
    case run
    case flush
    case nobs
    case go
    case thirtyOne
    case lastCard
    case hisHeels
    case bigHand
    case perfect29
    case skunk
    case doubleSkunk
    case win
    case lose
    case closeGame
}

// MARK: - Phrase Pack Protocol

protocol PhrasePack {
    var id: String { get }
    var displayName: String { get }
    func phrases(for event: PhraseEventType) -> [String]
}

extension PhrasePack {
    /// Returns a random phrase for the given event type.
    func randomPhrase(for event: PhraseEventType) -> String {
        let options = phrases(for: event)
        return options.randomElement() ?? ""
    }

    /// Returns a random phrase, interpolating points where applicable.
    func randomPhrase(for event: PhraseEventType, points: Int) -> String {
        let phrase = randomPhrase(for: event)
        return phrase.replacingOccurrences(of: "{points}", with: "\(points)")
    }
}
