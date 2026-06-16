import SwiftUI

@MainActor
final class SalonViewModel: ObservableObject {
    @Published var salons: [Salon] = []
    @Published var cities: [String] = []
    @Published var selectedCity: String = "الكل"
    @Published var selectedSalon: Salon?
    @Published var slots: [TimeSlot] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Fetch Salons
    func fetchSalons() async {
        isLoading = true
        defer { isLoading = false }
        do {
            var url = APIEndpoints.salons
            if selectedCity != "الكل" {
                url += "?city=\(selectedCity.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            }
            let response: SalonsResponse = try await APIClient.shared.get(url)
            salons = response.salons
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Fetch Cities
    func fetchCities() async {
        do {
            let response: CitiesResponse = try await APIClient.shared.get(APIEndpoints.cities)
            cities = ["الكل"] + response.cities
        } catch {
            cities = ["الكل"]
        }
    }

    // MARK: - Fetch Salon Detail
    func fetchSalon(id: Int) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let response: SalonResponse = try await APIClient.shared.get(APIEndpoints.salon(id))
            selectedSalon = response.salon
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Fetch Slots
    func fetchSlots(salonId: Int, date: String, serviceId: Int, staffId: Int? = nil) async {
        do {
            var url = "\(APIEndpoints.slots(salonId))?date=\(date)&service_id=\(serviceId)"
            if let staffId = staffId { url += "&staff_id=\(staffId)" }
            let response: SlotsResponse = try await APIClient.shared.get(url, requiresAuth: true)
            slots = response.slots
        } catch {
            slots = []
        }
    }

    // MARK: - Validate Coupon
    func validateCoupon(salonId: Int, code: String, price: Double) async throws -> CouponValidationResponse {
        return try await APIClient.shared.post(
            APIEndpoints.coupons(salonId),
            body: ["code": code, "price": price],
            requiresAuth: true
        )
    }
}
