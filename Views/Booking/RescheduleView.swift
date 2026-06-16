import SwiftUI

struct RescheduleView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var bookingVM: BookingViewModel
    @StateObject private var salonVM = SalonViewModel()

    let booking: Booking

    @State private var selectedDate = Date()
    @State private var selectedTime: String? = nil
    @State private var isSubmitting = false
    @State private var errorMessage: String? = nil

    private var dateString: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: selectedDate)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.luxeBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Reschedule count info
                        HStack {
                            Spacer()
                            Label(
                                "المرات المتبقية لإعادة الجدولة: \(booking.rescheduleRemaining)",
                                systemImage: "arrow.triangle.2.circlepath"
                            )
                            .font(.subheadline)
                            .foregroundColor(Color.luxeGold)
                        }
                        .padding(14)
                        .luxeCard()

                        // Date picker
                        VStack(alignment: .trailing, spacing: 10) {
                            SectionHeader(title: "اختاري التاريخ الجديد 📅")
                            DatePicker("", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .tint(Color.luxePrimary)
                                .environment(\.locale, Locale(identifier: "ar"))
                                .onChange(of: selectedDate) { _ in
                                    selectedTime = nil
                                    Task {
                                        await salonVM.fetchSlots(
                                            salonId: booking.salon.id,
                                            date: dateString,
                                            serviceId: booking.service.id
                                        )
                                    }
                                }
                        }
                        .padding(16)
                        .luxeCard()

                        // Slots
                        VStack(alignment: .trailing, spacing: 12) {
                            SectionHeader(title: "اختاري الوقت الجديد ⏰")
                            SlotGridView(slots: salonVM.slots, selectedTime: $selectedTime)
                        }
                        .padding(16)
                        .luxeCard()

                        LuxeButton(
                            title: "تأكيد إعادة الجدولة",
                            isLoading: isSubmitting,
                            isDisabled: selectedTime == nil
                        ) {
                            Task { await submitReschedule() }
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .navigationTitle("إعادة جدولة الموعد")
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
        }
        .task {
            await salonVM.fetchSlots(
                salonId: booking.salon.id,
                date: dateString,
                serviceId: booking.service.id
            )
        }
    }

    private func submitReschedule() async {
        guard let time = selectedTime else { return }
        isSubmitting = true
        defer { isSubmitting = false }
        do {
            try await bookingVM.reschedule(bookingId: booking.id, date: dateString, time: time)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
