import SwiftUI
import GoogleSignIn

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    var isLoggedIn: Bool { currentUser != nil }

    init() {
        Task { await loadCurrentUser() }
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleLogout),
            name: .userDidLogout, object: nil
        )
    }

    @objc private func handleLogout() {
        currentUser = nil
        KeychainHelper.shared.deleteToken()
    }

    // MARK: - Register
    func register(name: String, email: String, phone: String?, password: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            var body: [String: Any] = ["name": name, "email": email, "password": password, "role": "client"]
            if let phone = phone, !phone.isEmpty { body["phone"] = phone }
            let response: AuthResponse = try await APIClient.shared.post(APIEndpoints.register, body: body)
            KeychainHelper.shared.saveToken(response.token)
            currentUser = response.user
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Login
    func login(email: String, password: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let response: AuthResponse = try await APIClient.shared.post(
                APIEndpoints.login,
                body: ["email": email, "password": password]
            )
            KeychainHelper.shared.saveToken(response.token)
            currentUser = response.user
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Google Sign-In
    func signInWithGoogle() async {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
            guard let idToken = result.user.idToken?.tokenString else {
                errorMessage = "تعذّر الحصول على بيانات Google"
                return
            }
            let response: AuthResponse = try await APIClient.shared.post(
                APIEndpoints.googleAuth,
                body: ["id_token": idToken]
            )
            KeychainHelper.shared.saveToken(response.token)
            currentUser = response.user
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Load Current User
    func loadCurrentUser() async {
        guard KeychainHelper.shared.getToken() != nil else { return }
        do {
            let response: UserResponse = try await APIClient.shared.get(APIEndpoints.me, requiresAuth: true)
            currentUser = response.user
        } catch {
            KeychainHelper.shared.deleteToken()
        }
    }

    // MARK: - Change Password
    func changePassword(oldPassword: String, newPassword: String) async throws {
        let _: MessageResponse = try await APIClient.shared.post(
            APIEndpoints.changePassword,
            body: ["old_password": oldPassword, "new_password": newPassword],
            requiresAuth: true
        )
    }

    // MARK: - Logout
    func logout() {
        GIDSignIn.sharedInstance.signOut()
        KeychainHelper.shared.deleteToken()
        currentUser = nil
    }
}
