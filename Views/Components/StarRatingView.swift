import SwiftUI

struct StarRatingView: View {
    @Binding var rating: Int
    var maxRating: Int = 5
    var isInteractive: Bool = true
    var size: CGFloat = 30

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maxRating, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .foregroundColor(star <= rating ? Color.luxeGold : Color.gray.opacity(0.3))
                    .onTapGesture {
                        if isInteractive { rating = star }
                    }
            }
        }
    }
}

struct ReadonlyStarRating: View {
    let rating: Double
    var size: CGFloat = 14

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: iconName(for: star))
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .foregroundColor(Color.luxeGold)
            }
        }
    }

    private func iconName(for star: Int) -> String {
        if Double(star) <= rating { return "star.fill" }
        if Double(star) - rating < 1 { return "star.leadinghalf.filled" }
        return "star"
    }
}
