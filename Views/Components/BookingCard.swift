import SwiftUI

struct BookingCard: View {
    let booking: Booking
    var onCancel: (() -> Void)? = nil
    var onReschedule: (() -> Void)? = nil
    var onReview: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            // Header
            HStack {
                StatusBadge(status: booking.status, label: booking.statusDisplay)
                Spacer()
                Text(booking.salon.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color.luxeText)
            }

            Divider()

            // Service & Date
            VStack(alignment: .trailing, spacing: 6) {
                InfoRow(icon: "scissors", text: booking.service.name)
                InfoRow(icon: "calendar", text: "\(booking.date) | \(booking.time)")
                if let staff = booking.staff {
                    InfoRow(icon: "person", text: staff.name)
                }
            }

            // Price
            HStack {
                VStack(alignment: .leading) {
                    if booking.discountAmount > 0 {
                        Text("\(String(format: "%.0f", booking.price)) ر.س")
                            .strikethrough()
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    Text("\(String(format: "%.0f", booking.finalPrice)) ر.س")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.luxePrimary)
                }
                Spacer()
                if booking.pointsEarned > 0 {
                    Label("\(booking.pointsEarned) نقطة", systemImage: "star.fill")
                        .font(.caption)
                        .foregroundColor(Color.luxeGold)
                }
            }

            // Actions
            if booking.status == "pending" || booking.status == "confirmed" {
                HStack(spacing: 8) {
                    if booking.rescheduleRemaining > 0 {
                        Button("إعادة جدولة") { onReschedule?() }
                            .buttonStyle(OutlineButtonStyle(color: Color.luxeGold))
                    }
                    Button("إلغاء") { onCancel?() }
                        .buttonStyle(OutlineButtonStyle(color: .red))
                }
            }

            if booking.status == "completed" && !booking.hasReview {
                Button("قيّمي تجربتك ⭐") { onReview?() }
                    .goldButton()
                    .font(.subheadline)
            }
        }
        .padding(16)
        .luxeCard()
    }
}

struct StatusBadge: View {
    let status: String
    let label: String

    var color: Color {
        switch status {
        case "pending":   return .orange
        case "confirmed": return .green
        case "completed": return .blue
        case "cancelled": return Color.gray
        default:          return Color.gray
        }
    }

    var body: some View {
        Text(label)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .cornerRadius(20)
    }
}

struct InfoRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.subheadline)
                .foregroundColor(Color.luxeText)
            Image(systemName: icon)
                .foregroundColor(Color.luxePrimary)
                .font(.subheadline)
        }
    }
}

struct OutlineButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(color.opacity(0.08))
            .cornerRadius(10)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
