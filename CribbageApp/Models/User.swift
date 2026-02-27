import Foundation

struct User: Codable, Identifiable {
    let id: String
    var displayName: String
    var avatarEmoji: String
    var friendCode: String
    var appleLinked: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case avatarEmoji = "avatar_emoji"
        case friendCode = "friend_code"
        case appleLinked = "apple_linked"
    }
}

struct Friend: Codable, Identifiable {
    let id: String
    let userId: String
    var displayName: String
    var avatarEmoji: String
    var friendCode: String
    var isOnline: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case displayName = "display_name"
        case avatarEmoji = "avatar_emoji"
        case friendCode = "friend_code"
        case isOnline = "is_online"
    }
}

struct GameInvite: Codable, Identifiable {
    let id: String
    let fromUser: User
    let toUser: User
    var status: String
    var gameId: String?
    let createdAt: String
    let expiresAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case fromUser = "from_user"
        case toUser = "to_user"
        case status
        case gameId = "game_id"
        case createdAt = "created_at"
        case expiresAt = "expires_at"
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let sender: String
    let text: String
    let isFromMe: Bool
    let timestamp: Date
}
