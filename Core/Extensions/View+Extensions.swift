import SwiftUI

extension View {
    func luxeCard() -> some View {
        self
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.luxePrimary.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    func primaryButton() -> some View {
        self
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [Color.luxePrimary, Color.luxePrimary.opacity(0.85)],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .cornerRadius(14)
    }

    func goldButton() -> some View {
        self
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [Color.luxeGold, Color.luxeGold.opacity(0.85)],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .cornerRadius(14)
    }
}
