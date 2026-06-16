import SwiftUI

struct ReviewView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var bookingVM: BookingViewModel

    let booking: Booking

    @State private var salonRating = 0
    @State private var staffRating = 0
    @State private var comment = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color.luxeBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 48))
                                .foregroundColor(Color.luxeGold)
                            Text("قيّمي تجربتكِ")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color.luxeText)
                            Text(booking.salon.name)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)

                        // Salon rating
                        VStack(alignment: .trailing, spacing: 14) {
                            SectionHeader(title: "تقييم الصالون")
                            HStack {
                                Spacer()
                                StarRatingView(rating: $salonRating, size: 36)
                            }
                            RatingLabel(rating: salonRating)
                        }
                        .padding(16)
                        .luxeCard()

                        // Staff rating (only if booking has staff)
                        if let staff = booking.staff {
                            VStack(alignment: .trailing, spacing: 14) {
                                SectionHeader(title: "تقييم \(staff.name)")
                                HStack {
                                    Spacer()
                                    StarRatingView(rating: $staffRating, size: 36)
                                }
                                RatingLabel(rating: staffRating)
                            }
                            .padding(16)
                            .luxeCard()
                        }

                        // Comment
                        VStack(alignment: .trailing, spacing: 10) {
                            SectionHeader(title: "تعليق (اختياري) 💬")
                            TextEditor(text: $comment)
                                .frame(height: 120)
                                .padding(10)
                                .background(Color.luxeBackground)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.luxePrimary.opacity(0.2), lineWidth: 1))
                        }
                        .padding(16)
                        .luxeCard()

                        LuxeButton(
                            title: "إرسال التقييم ✨",
                            isGold: true,
                            isLoading: isSubmitting,
                            isDisabled: salonRating == 0
                        ) {
                            Task { await submitReview() }
                        }
                        .padding(.bottom, 30)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .navigationTitle("تقييم التجربة")
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
    }

    private func submitReview() async {
        isSubmitting = true
        defer { isSubmitting = false }
        do {
            try await bookingVM.submitReview(
                bookingId: booking.id,
                rating: salonRating,
                staffRating: booking.staff != nil && staffRating > 0 ? staffRating : nil,
                comment: comment.isEmpty ? nil : comment
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct RatingLabel: View {
    let rating: Int
    var label: String {
        switch rating {
        case 1: return "سيء 😔"
        case 2: return "مقبول 😐"
        case 3: return "جيد 🙂"
        case 4: return "جيد جداً 😊"
        case 5: return "ممتاز 🤩"
        default: return "اختاري تقييماً"
        }
    }
    var body: some View {
        Text(label)
            .font(.subheadline)
            .foregroundColor(rating > 0 ? Color.luxeGold : .secondary)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}
