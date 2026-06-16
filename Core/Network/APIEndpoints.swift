import Foundation

enum APIEndpoint {
    static let base = "https://luxe-sa.com/api/v1"

    // Auth
    static let register       = "\(base)/auth/register"
    static let login          = "\(base)/auth/login"
    static let googleAuth     = "\(base)/auth/google"
    static let me             = "\(base)/auth/me"
    static let changePassword = "\(base)/auth/change-password"

    // Salons
    static let salons         = "\(base)/salons"
    static let cities         = "\(base)/cities"

    static func salon(_ id: Int)   -> String { "\(base)/salons/\(id)" }
    static func slots(_ id: Int)   -> String { "\(base)/salons/\(id)/slots" }
    static func coupons(_ id: Int) -> String { "\(base)/salons/\(id)/coupons/validate" }

    // Bookings
    static let bookings            = "\(base)/bookings"
    static func booking(_ id: Int) -> String { "\(base)/bookings/\(id)" }
    static func cancel(_ id: Int)  -> String { "\(base)/bookings/\(id)/cancel" }
    static func reschedule(_ id: Int) -> String { "\(base)/bookings/\(id)/reschedule" }
    static func review(_ id: Int)  -> String { "\(base)/bookings/\(id)/review" }
}
