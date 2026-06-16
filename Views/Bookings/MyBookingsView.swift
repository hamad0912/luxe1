import SwiftUI

struct MyBookingsView: View {
    @EnvironmentObject var bookingVM: BookingViewModel
    @State private var filterStatus = "الكل"
    @State private var bookingToCancel: Booking? = nil
    @State private var bookingToReschedule: Booking? = nil
    @State private var bookingToReview: Booking? = nil

    let filters = ["الكل", "قادمة", "مكتملة", "ملغاة"]

    var filteredBookings: [Booking] {
        switch filterStatus {
        case "قادمة":   return bookingVM.bookings.filter { ["pending","confirmed"].contains($0.status) }
        case "مكتملة":  return bookingVM.bookings.filter { $0.status == "completed" }
        case "ملغاة":   return bookingVM.bookings.filter { $0.status == "cancelled" }
        default:        return bookingVM.bookings
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.luxeBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Filter Picker
                    Picker("", selection: $filterStatus) {
                        ForEach(filters, id: \.self) { filter in
                            Text(filter).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    if bookingVM.isLoading {
                        Spacer()
                        ProgressView().tint(Color.luxePrimary)
                        Spacer()
                    } else if filteredBookings.isEmpty {
                        Spacer()
                        VStack(spacing: 14) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 48))
                                .foregroundColor(Color.luxePrimary.opacity(0.3))
                            Text("لا توجد حجوزات")
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 14) {
                                ForEach(filteredBookings) { booking in
                                    BookingCard(
                                        booking: booking,
                                        onCancel: { bookingToCancel = booking },
                                        onReschedule: { bookingToReschedule = booking },
                                        onReview: { bookingToReview = booking }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationTitle("حجوزاتي 📋")
            .navigationBarTitleDisplayMode(.large)
            .confirmationDialog("هل تريدين إلغاء الحجز؟", isPresented: .constant(bookingToCancel != nil), titleVisibility: .visible) {
                Button("نعم، إلغاء الحجز", role: .destructive) {
                    if let b = bookingToCancel {
                        Task { await bookingVM.cancelBooking(id: b.id) }
                    }
                    bookingToCancel = nil
                }
                Button("لا", role: .cancel) { bookingToCancel = nil }
            }
            .sheet(item: $bookingToReschedule) { booking in
                RescheduleView(booking: booking)
                    .environmentObject(bookingVM)
            }
            .sheet(item: $bookingToReview) { booking in
                ReviewView(booking: booking)
                    .environmentObject(bookingVM)
            }
            .alert("خطأ", isPresented: .constant(bookingVM.errorMessage != nil)) {
                Button("حسناً") { bookingVM.errorMessage = nil }
            } message: { Text(bookingVM.errorMessage ?? "") }
        }
        .task { await bookingVM.fetchBookings() }
    }
}
