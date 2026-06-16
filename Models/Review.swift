import Foundation

struct Review: Codable, Identifiable {
    let id: Int
    let rating: Int
    let staffRating: Int?
    let comment: String?
    let createdAt: String?
    let userName: String?

    enum CodingKeys: String, CodingKey {
        case id, rating, comment
        case staffRating = "staff_rating"
        case createdAt = "created_at"
        case userName = "user_name"
    }
}

struct Coupon: Codable, Identifiable {
    let id: Int
    let code: String
    let discountType: String
    let discountValue: Double
    let minOrderAmount: Double?

    enum CodingKeys: String, CodingKey {
        case id, code
        case discountType = "discount_type"
        case discountValue = "discount_value"
        case minOrderAmount = "min_order_amount"
    }

    var displayText: String {
        if discountType == "percentage" {
            return "\(Int(discountValue))% خصم"
        } else {
            return "\(Int(discountValue)) ر.س خصم"
        }
    }
}
