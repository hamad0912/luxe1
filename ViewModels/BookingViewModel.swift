import SwiftUI

@MainActor
final class BookingViewModel: ObservableObject {
    @Published var bookings: [Booking] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    // MARK: - Fetch Bookings
    func fetchBookings() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let response: BookingsResponse = try await APIClient.shared.get(APIEndpoints.bookings, requiresAuth: true)
            bookings = response.bookings
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Create Booking
    func createBooking(
        salonId: Int, serviceId: Int, staffId: Int?,
        date: String, time: String, notes: String?,
        couponCode: String?, usePoints: Bool
    ) async throws -> Booking {
        var body: [String: Any] = [
            "salon_id": salonId,
            "service_id": serviceId,
            "date": date,
            "time": time,
            "use_points": usePoints
        ]
        if let staffId = staffId { body["staff_id"] = staffId }
        if let notes = notes, !notes.isEmpty { body["notes"] = notes }
        if let couponCode = couponCode, !couponCode.isEmpty { body["coupon_code"] = couponCode }

        let response: BookingResponse = try await APIClient.shared.post(
            APIEndpoints.bookings, body: body, requiresAuth: true
        )
        return response.booking
    }

    // MARK: - Cancel Booking
    func cancelBooking(id: Int) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let _: MessageResponse = try await APIClient.shared.post(APIEndpoints.cancel(id), requiresAuth: true)
            await fetchBookings()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Reschedule
    func reschedule(bookingId: Int, date: String, time: String) async throws {
        let _: MessageResponse = try await APIClient.shared.post(
            APIEndpoints.reschedule(bookingId),
            body: ["date": date, "time": time],
            requiresAuth: true
        )
        await fetchBookings()
    }

    // MARK: - Review
    func submitReview(bookingId: Int, rating: Int, staffRating: Int?, comment: String?) async throws {
        var body: [String: Any] = ["rating": rating]
        if let staffRating = staffRating { body["staff_rating"] = staffRating }
        if let comment = comment, !comment.isEmpty { body["comment"] = comment }
        let _: MessageResponse = try await APIClient.shared.post(
            APIEndpoints.review(bookingId), body: body, requiresAuth: true
        )
        await fetchBookings()
    }
}
