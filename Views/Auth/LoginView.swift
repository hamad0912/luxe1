import SwiftUI
import SafariServices

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    @State private var showSafari = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.luxeBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        // Logo header
                        VStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 52))
                                .foregroundColor(Color.luxePrimary)
                            Text("لوكس")
                                .font(.system(size: 38, weight: .bold))
                                .foregroundColor(Color.luxeText)
                            Text("منصة حجوزات صالونات التجميل")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 60)

                        // Form Card
                        VStack(spacing: 16) {
                            LuxeTextField(placeholder: "البريد الإلكتروني", text: $email, icon: "envelope")
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)

                            LuxeTextField(placeholder: "كلمة المرور", text: $password, icon: "lock", isSecure: true)

                            Button("نسيت كلمة المرور؟") { showSafari = true }
                                .font(.footnote)
                                .foregroundColor(Color.luxePrimary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(20)
                        .luxeCard()

                        // Buttons
                        VStack(spacing: 12) {
                            LuxeButton(title: "دخول", isLoading: authVM.isLoading) {
                                Task { await authVM.login(email: email, password: password) }
                            }

                            DividerWithText(text: "أو")

                            GoogleSignInButton {
                                Task { await authVM.signInWithGoogle() }
                            }
                        }

                        // Register link
                        NavigationLink(destination: RegisterView()) {
                            HStack(spacing: 4) {
                                Text("سجّلي الآن")
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.luxePrimary)
                                Text("ليس لديك حساب؟")
                                    .foregroundColor(.secondary)
                            }
                            .font(.subheadline)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .alert("خطأ", isPresented: .constant(authVM.errorMessage != nil)) {
                Button("حسناً") { authVM.errorMessage = nil }
            } message: {
                Text(authVM.errorMessage ?? "")
            }
            .sheet(isPresented: $showSafari) {
                SafariView(url: URL(string: "https://luxe-sa.com/forgot-password")!)
            }
        }
    }
}

// MARK: - Supporting Views

struct LuxeTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String
    var isSecure: Bool = false

    var body: some View {
        HStack(spacing: 10) {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textContentType(.password)
            } else {
                TextField(placeholder, text: $text)
            }
            Image(systemName: icon)
                .foregroundColor(Color.luxePrimary.opacity(0.7))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.luxeBackground)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.luxePrimary.opacity(0.2), lineWidth: 1))
    }
}

struct DividerWithText: View {
    let text: String
    var body: some View {
        HStack {
            Rectangle().frame(height: 1).foregroundColor(.secondary.opacity(0.3))
            Text(text).font(.caption).foregroundColor(.secondary).padding(.horizontal, 8)
            Rectangle().frame(height: 1).foregroundColor(.secondary.opacity(0.3))
        }
    }
}

struct GoogleSignInButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: "globe")
                    .font(.body)
                Text("تسجيل الدخول بـ Google")
                    .fontWeight(.semibold)
            }
            .foregroundColor(Color.luxeText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    func updateUIViewController(_ uiVC: SFSafariViewController, context: Context) {}
}
