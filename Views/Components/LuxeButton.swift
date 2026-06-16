import SwiftUI

struct LuxeButton: View {
    let title: String
    var isGold: Bool = false
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView().tint(.white)
                }
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
        }
        .disabled(isDisabled || isLoading)
        .opacity((isDisabled || isLoading) ? 0.65 : 1)
        .if(isGold) { $0.goldButton() }
        .if(!isGold) { $0.primaryButton() }
    }
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition { transform(self) } else { self }
    }
}
