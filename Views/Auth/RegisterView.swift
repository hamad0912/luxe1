import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var validationError: String?

    var body: some View {
        ZStack {
            Color.luxeBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 6) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 44))
                            .foregroundColor(Color.luxePrimary)
                        Text("إنشاء حساب جديد")
                            .font(.title2).fontWeight(.bold)
                            .foregroundColor(Color.luxeText)
                    }
                    .padding(.top, 40)

                    // Form
                    VStack(spacing: 14) {
                        LuxeTextField(placeholder: "الاسم الكامل", text: $name, icon: "person")
                        LuxeTextField(placeholder: "البريد الإلكتروني", text: $email, icon: "envelope")
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                        LuxeTextField(placeholder: "رقم الجوال (اختياري)", text: $phone, icon: "phone")
                            .keyboardType(.phonePad)
                        LuxeTextField(placeholder: "كلمة المرور", text: $password, icon: "lock", isSecure: true)
                        LuxeTextField(placeholder: "تأكيد كلمة المرور", text: $confirmPassword, icon: "lock.fill", isSecure: true)
                    }
                    .padding(20)
                    .luxeCard()

                    if let err = validationError {
                        Text(err)
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }

                    VStack(spacing: 12) {
                        LuxeButton(title: "إنشاء حساب", isLoading: authVM.isLoading) {
                            validate()
                        }

                        DividerWithText(text: "أو")

                        GoogleSignInButton {
                            Task { await authVM.signInWithGoogle() }
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationTitle("التسجيل")
        .navigationBarTitleDisplayMode(.inline)
        .alert("خطأ", isPresented: .constant(authVM.errorMessage != nil)) {
            Button("حسناً") { authVM.errorMessage = nil }
        } message: {
            Text(authVM.errorMessage ?? "")
        }
    }

    private func validate() {
        validationError = nil
        guard !name.isEmpty else { validationError = "الاسم مطلوب"; return }
        guard !email.isEmpty else { validationError = "البريد مطلوب"; return }
        guard password.count >= 6 else { validationError = "كلمة المرور 6 أحرف على الأقل"; return }
        guard password == confirmPassword else { validationError = "كلمتا المرور غير متطابقتين"; return }
        Task { await authVM.register(name: name, email: email, phone: phone.isEmpty ? nil : phone, password: password) }
    }
}
