import SwiftUI

struct SlotGridView: View {
    let slots: [TimeSlot]
    @Binding var selectedTime: String?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    var body: some View {
        if slots.isEmpty {
            Text("لا توجد أوقات متاحة")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
        } else {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(slots) { slot in
                    SlotCell(slot: slot, isSelected: selectedTime == slot.time) {
                        if slot.status == "available" {
                            selectedTime = slot.time
                        }
                    }
                }
            }
        }
    }
}

struct SlotCell: View {
    let slot: TimeSlot
    let isSelected: Bool
    let onTap: () -> Void

    var backgroundColor: Color {
        if isSelected { return Color.luxePrimary }
        switch slot.status {
        case "available": return Color.slotAvailable
        case "booked":    return Color.slotBooked
        default:          return Color.slotPast
        }
    }

    var textColor: Color {
        if isSelected { return .white }
        switch slot.status {
        case "available": return Color(red: 0.2, green: 0.6, blue: 0.3)
        case "booked":    return Color(red: 0.8, green: 0.2, blue: 0.2)
        default:          return .gray
        }
    }

    var body: some View {
        Button(action: onTap) {
            Text(slot.time)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(backgroundColor)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.luxePrimary : Color.clear, lineWidth: 2)
                )
        }
        .disabled(slot.status != "available")
    }
}
