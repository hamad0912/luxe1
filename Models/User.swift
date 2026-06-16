import Foundation

struct User: Codable, Identifiable {
    let id: Int
    var name: String
    var email: String
    var phone: String?
    let role: String
    var loyaltyPoints: Int
    var cancellationRate: Int
    var hasPassword: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, email, phone, role
        case loyaltyPoints = "loyalty_points"
        case cancellationRate = "cancellation_rate"
        case hasPassword = "has_password"
    }
}

struct AuthResponse: Codable {
    let token: String
    let user: User
}

struct UserResponse: Codable {
    let user: User
}

struct MessageResponse: Codable {
    let message: String
}
