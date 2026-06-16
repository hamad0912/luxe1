import SwiftUI

struct BookingView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var salonVM = SalonViewModel()

    let salon: Salon
    let service: Service
    let staffId: Int?

    @State private var selectedDate = Date()
    @State private var selectedTime: String? = nil
    @State private var couponCode = ""
    @State private var couponResult: CouponValidationResponse? = nil
    @State private var isCouponLoading = false
    @State private var usePoints = false
    @State private var notes = ""
    @State private var isBooking = false
    @State private var errorMessage: String? = nil
    @State private var bookingSuccess = false

    private var dateString: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: selectedDate)
    }

    private var finalPrice: Double {
        couponResult?.finalPrice ?? service.price
    }

    private var discount: Double {
        couponResult?.discountAmount ?? 0
    }

    private var loyaltyPoints: Int {
        authVM.currentUser?.loyaltyPoints ?? 0
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.luxeBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Service summary
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(service.duration) دقيقة")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(String(format: "%.0f", service.price)) ر.س")
                                    .font(.headline)
                                    .foregroundColor(Color.luxePrimary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("الخدمة")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(service.name)
                                    .font(.headline)
                                    .foregroundColor(Color.luxeText)
                            }
                        }
                        .padding(16)
                        .luxeCard()

                        // Date picker
                        VStack(alignment: .trailing, spacing: 10) {
                            SectionHeader(title: "اختاري التاريخ 📅")
                            DatePicker("", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .tint(Color.luxePrimary)
                                .environment(\.locale, Locale(identifier: "ar"))
                                .onChange(of: selectedDate) { _ in
                                    selectedTime = nil
                                    Task {
                                        await salonVM.fetchSlots(
                                            salonId: salon.id,
                                            date: dateString,
                                            serviceId: service.id,
                                            staffId: staffId
                                        )
                                    }
                                }
                        }
                        .padding(16)
                        .luxeCard()

                        // Slots
                        VStack(alignment: .trailing, spacing: 12) {
                            SectionHeader(title: "اختاري الوقت ⏰")
                            SlotGridView(slots: salonVM.slots, selectedTime: $selectedTime)
                        }
                        .padding(16)
                        .luxeCard()

                        // Coupon
                        VStack(alignment: .trailing, spacing: 12) {
                            SectionHeader(title: "كود الخصم 🏷️")
                            HStack(spacing: 10) {
                                Button("تطبيق") {
                                    Task { await applyCoupon() }
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.luxeGold)
                                .cornerRadius(10)
                                .disabled(couponCode.isEmpty || isCouponLoading)

                                TextField("أدخلي كود الخصم", text: $couponCode)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(Color.luxeBackground)
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.luxePrimary.opacity(0.2), lineWidth: 1))
                            }

                            if let result = couponResult {
                                if result.valid == true, let discount = result.discountAmount {
                                    HStack {
                                        Spacer()
                                        Label("خصم \(String(format: "%.0f", discount)) ر.س", systemImage: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.subheadline)
                                    }
                                } else if let err = result.error {
                                    HStack {
                                        Spacer()
                                        Label(err, systemImage: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                            .font(.subheadline)
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .luxeCard()

                        // Points toggle
                        if loyaltyPoints >= 100 {
                            HStack {
                                Text("نقاطي: \(loyaltyPoints) نقطة")
                                    .font(.subheadline)
                                    .foregroundColor(Color.luxeGold)
                                Spacer()
                                Toggle("استخدام نقاط الولاء 🎁", isOn: $usePoints)
                                    .tint(Color.luxeGold)
                                    .labelsHidden()
                                Text("استخدام نقاط الولاء 🎁")
                                    .font(.subheadline)
                                    .foregroundColor(Color.luxeText)
                            }
                            .padding(16)
                            .luxeCard()
                        }

                        // Notes
                        VStack(alignment: .trailing, spacing: 8) {
                            SectionHeader(title: "ملاحظات (اختياري)")
                            TextEditor(text: $notes)
                                .frame(height: 80)
                                .padding(8)
                                .background(Color.luxeBackground)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.luxePrimary.opacity(0.2), lineWidth: 1))
                        }
                        .padding(16)
                        .luxeCard()

                        // Price summary
                        VStack(alignment: .trailing, spacing: 8) {
                            SectionHeader(title: "ملخص السعر")
                            HStack {
                                Text("\(String(format: "%.0f", finalPrice)) ر.س")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.luxePrimary)
                                Spacer()
                                if discount > 0 {
                                    Text("\(String(format: "%.0f", service.price)) ر.س")
                                        .strikethrough()
                                        .foregroundColor(.secondary)
                                }
                                Text("السعر:")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(16)
                        .luxeCard()

                        // Confirm button
                        LuxeButton(
                            title: "تأكيد الحجز ✨",
                            isLoading: isBooking,
                            isDisabled: selectedTime == nil
                        ) {
                            Task { await confirmBooking() }
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .navigationTitle("حجز موعد")
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
            .alert("تم الحجز بنجاح! 🎉", isPresented: $bookingSuccess) {
                Button("رائع") { dismiss() }
            } message: {
                Text("سيتم التواصل معكِ لتأكيد الموعد")
            }
        }
        .task {
            await salonVM.fetchSlots(salonId: salon.id, date: dateString, serviceId: service.id, staffId: staffId)
        }
    }

    private func applyCoupon() async {
        isCouponLoading = true
        defer { isCouponLoading = false }
        do {
            couponResult = try await salonVM.validateCoupon(
                salonId: salon.id, code: couponCode, price: service.price
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func confirmBooking() async {
        guard let time = selectedTime else { return }
        isBooking = true
        defer { isBooking = false }
        do {
            let bookingVM = BookingViewModel()
            let _ = try await bookingVM.createBooking(
                salonId: salon.id,
                serviceId: service.id,
                staffId: staffId,
                date: dateString,
                time: time,
                notes: notes.isEmpty ? nil : notes,
                couponCode: couponResult?.valid == true ? couponCode : nil,
                usePoints: usePoints
            )
            bookingSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
