import Foundation

struct Booking: Codable, Identifiable {
    let id: Int
    let status: String
    let salon: BookingSalon
    let service: BookingService
    let staff: BookingStaff?
    let date: String
    let time: String
    let notes: String?
    let price: Double
    let discountAmount: Double
    let finalPrice: Double
    let couponCode: String?
    let pointsEarned: Int
    let pointsRedeemed: Int
    let rescheduleCount: Int
    let rescheduleRemaining: Int
    let hasReview: Bool
    let review: BookingReview?

    enum CodingKeys: String, CodingKey {
        case id, status, salon, service, staff, date, time, notes, price, review
        case discountAmount = "discount_amount"
        case finalPrice = "final_price"
        case couponCode = "coupon_code"
        case pointsEarned = "points_earned"
        case pointsRedeemed = "points_redeemed"
        case rescheduleCount = "reschedule_count"
        case rescheduleRemaining = "reschedule_remaining"
        case hasReview = "has_review"
    }

    var statusDisplay: String {
        switch status {
        case "pending":   return "قيد الانتظار"
        case "confirmed": return "مؤكد"
        case "completed": return "مكتمل"
        case "cancelled": return "ملغي"
        default:          return status
        }
    }

    var statusColor: String {
        switch status {
        case "pending":   return "orange"
        case "confirmed": return "green"
        case "completed": return "blue"
        case "cancelled": return "gray"
        default:          return "gray"
        }
    }
}

struct BookingSalon: Codable {
    let id: Int
    let name: String
    let logoUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case logoUrl = "logo_url"
    }
}

struct BookingService: Codable {
    let id: Int
    let name: String
    let duration: Int?
}

struct BookingStaff: Codable {
    let id: Int
    let name: String
}

struct BookingReview: Codable {
    let rating: Int
    let staffRating: Int?
    let comment: String?

    enum CodingKeys: String, CodingKey {
        case rating
        case staffRating = "staff_rating"
        case comment
    }
}

struct BookingsResponse: Codable {
    let bookings: [Booking]
}

struct BookingResponse: Codable {
    let booking: Booking
    let message: String?
}
