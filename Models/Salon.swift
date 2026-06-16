import Foundation

struct Salon: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let city: String?
    let address: String?
    let phone: String?
    let logoUrl: String?
    let averageRating: Double?
    let reviewsCount: Int
    var services: [Service]
    var staff: [Staff]
    var workingHours: [WorkingHours]
    var reviews: [Review]
    var activeCoupons: [Coupon]

    enum CodingKeys: String, CodingKey {
        case id, name, description, city, address, phone
        case logoUrl = "logo_url"
        case averageRating = "average_rating"
        case reviewsCount = "reviews_count"
        case services, staff
        case workingHours = "working_hours"
        case reviews
        case activeCoupons = "active_coupons"
    }

    var fullLogoURL: URL? {
        guard let logo = logoUrl else { return nil }
        let full = logo.hasPrefix("http") ? logo : "https://luxe-sa.com\(logo)"
        return URL(string: full)
    }
}

struct Service: Codable, Identifiable {
    let id: Int
    let name: String
    let price: Double
    let duration: Int
    let category: String?
}

struct Staff: Codable, Identifiable {
    let id: Int
    let name: String
    let specialty: String?
    let averageRating: Double?

    enum CodingKeys: String, CodingKey {
        case id, name, specialty
        case averageRating = "average_rating"
    }
}

struct WorkingHours: Codable, Identifiable {
    var id: Int { dayOfWeek }
    let dayOfWeek: Int
    let openTime: String?
    let closeTime: String?
    let isClosed: Bool

    enum CodingKeys: String, CodingKey {
        case dayOfWeek = "day_of_week"
        case openTime = "open_time"
        case closeTime = "close_time"
        case isClosed = "is_closed"
    }
}

struct SalonsResponse: Codable {
    let salons: [Salon]
    let total: Int?
}

struct SalonResponse: Codable {
    let salon: Salon
}

struct CitiesResponse: Codable {
    let cities: [String]
}

struct TimeSlot: Codable, Identifiable {
    var id: String { time }
    let time: String
    let status: String
}

struct SlotsResponse: Codable {
    let slots: [TimeSlot]
}

struct CouponValidationResponse: Codable {
    let valid: Bool?
    let discountAmount: Double?
    let finalPrice: Double?
    let error: String?

    enum CodingKeys: String, CodingKey {
        case valid
        case discountAmount = "discount_amount"
        case finalPrice = "final_price"
        case error
    }
}
