import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showChangePassword = false
    @State private var showLogoutConfirm = false

    var user: User? { authVM.currentUser }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.luxeBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        // Avatar + basic info
                        VStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.luxePrimary, Color.luxeGold],
                                            startPoint: .topLeading, endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                Text(user?.name.prefix(1).uppercased() ?? "?")
                                    .font(.system(size: 34, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            Text(user?.name ?? "")
                                .font(.title3).fontWeight(.bold)
                                .foregroundColor(Color.luxeText)
                            Text(user?.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            if let phone = user?.phone {
                                Text(phone)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(24)
                        .luxeCard()

                        // Loyalty Points - Gold Card
                        VStack(spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("كل 100 نقطة = خصم 10 ر.س")
                                        .font(.caption)
                                        .foregroundColor(Color.luxeGold.opacity(0.8))
                                    Text("نقاط الولاء 🎁")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(user?.loyaltyPoints ?? 0)")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("نقطة")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            LinearGradient(
                                colors: [Color.luxeGold, Color(red: 0.7, green: 0.55, blue: 0.3)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: Color.luxeGold.opacity(0.3), radius: 10, x: 0, y: 4)

                        // Cancellation rate
                        if let rate = user?.cancellationRate, rate > 0 {
                            HStack {
                                Spacer()
                                Label("معدل الإلغاء: \(rate)%", systemImage: "exclamationmark.triangle.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.orange)
                            }
                            .padding(14)
                            .background(Color.orange.opacity(0.08))
                            .cornerRadius(12)
                        }

                        // Actions
                        VStack(spacing: 0) {
                            if user?.hasPassword == true {
                                ProfileActionRow(icon: "lock.rotation", title: "تغيير كلمة المرور") {
                                    showChangePassword = true
                                }
                                Divider().padding(.horizontal, 16)
                            }
                            ProfileActionRow(icon: "arrow.right.square", title: "تسجيل الخروج", isDestructive: true) {
                                showLogoutConfirm = true
                            }
                        }
                        .luxeCard()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("ملفي الشخصي 👤")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showChangePassword) {
                ChangePasswordSheet()
                    .environmentObject(authVM)
            }
            .confirmationDialog("هل تريدين تسجيل الخروج؟", isPresented: $showLogoutConfirm, titleVisibility: .visible) {
                Button("تسجيل الخروج", role: .destructive) { authVM.logout() }
                Button("إلغاء", role: .cancel) {}
            }
        }
    }
}

struct ProfileActionRow: View {
    let icon: String
    let title: String
    var isDestructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color.secondary.opacity(0.4))
                Spacer()
                Text(title)
                    .font(.body)
                    .foregroundColor(isDestructive ? .red : Color.luxeText)
                Image(systemName: icon)
                    .foregroundColor(isDestructive ? .red : Color.luxePrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }
}

struct ChangePasswordSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel

    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var success = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.luxeBackground.ignoresSafeArea()

                VStack(spacing: 20) {
                    Spacer()
                    VStack(spacing: 16) {
                        LuxeTextField(placeholder: "كلمة المرور الحالية", text: $oldPassword, icon: "lock", isSecure: true)
                        LuxeTextField(placeholder: "كلمة المرور الجديدة", text: $newPassword, icon: "lock.fill", isSecure: true)
                    }
                    .padding(20)
                    .luxeCard()

                    LuxeButton(title: "تغيير كلمة المرور", isLoading: isLoading) {
                        Task { await changePassword() }
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .navigationTitle("تغيير كلمة المرور")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("إغلاق") { dismiss() }
                        .foregroundColor(Color.luxePrimary)
                }
            }
            .alert("خطأ", isPresented: .constant(errorMessage != nil)) {
                Button("حسناً") { errorMessage = nil }
            } message: { Text(errorMessage ?? "") }
            .alert("تم التغيير بنجاح ✅", isPresented: $success) {
                Button("حسناً") { dismiss() }
            }
        }
    }

    private func changePassword() async {
        guard !oldPassword.isEmpty, !newPassword.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await authVM.changePassword(oldPassword: oldPassword, newPassword: newPassword)
            success = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
