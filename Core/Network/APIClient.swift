import Foundation

enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}

enum APIError: LocalizedError {
    case invalidURL
    case unauthorized
    case serverError(String)
    case decodingError(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:          return "رابط غير صحيح"
        case .unauthorized:        return "انتهت جلستك، يرجى تسجيل الدخول مجدداً"
        case .serverError(let msg): return msg
        case .decodingError(let e): return "خطأ في قراءة البيانات: \(e.localizedDescription)"
        case .unknown:             return "حدث خطأ غير متوقع"
        }
    }
}

struct APIErrorResponse: Codable {
    let error: String?
    let message: String?
    var displayMessage: String { error ?? message ?? "حدث خطأ" }
}

final class APIClient {
    static let shared = APIClient()
    private init() {}

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    // MARK: - Core request
    func request<T: Decodable>(
        url urlString: String,
        method: HTTPMethod = .GET,
        body: [String: Any]? = nil,
        requiresAuth: Bool = false
    ) async throws -> T {
        guard let url = URL(string: urlString) else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if requiresAuth {
            if let token = KeychainHelper.shared.getToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }

        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else { throw APIError.unknown }

        if http.statusCode == 401 {
            KeychainHelper.shared.deleteToken()
            NotificationCenter.default.post(name: .userDidLogout, object: nil)
            throw APIError.unauthorized
        }

        if !(200...299).contains(http.statusCode) {
            if let errResp = try? decoder.decode(APIErrorResponse.self, from: data) {
                throw APIError.serverError(errResp.displayMessage)
            }
            throw APIError.serverError("خطأ \(http.statusCode)")
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    // MARK: - Convenience
    func get<T: Decodable>(_ url: String, requiresAuth: Bool = false) async throws -> T {
        try await request(url: url, method: .GET, requiresAuth: requiresAuth)
    }

    func post<T: Decodable>(_ url: String, body: [String: Any]? = nil, requiresAuth: Bool = false) async throws -> T {
        try await request(url: url, method: .POST, body: body, requiresAuth: requiresAuth)
    }
}

extension Notification.Name {
    static let userDidLogout = Notification.Name("userDidLogout")
}
