import SwiftUI

enum FocusStyle {
    static let ink = Color(red: 0.14, green: 0.22, blue: 0.20)
    static let paper = Color(red: 0.96, green: 0.96, blue: 0.91)
    static let moss = Color(red: 0.27, green: 0.40, blue: 0.30)
    static let pale = Color(red: 0.88, green: 0.92, blue: 0.82)
}

struct Card: ViewModifier {
    func body(content: Content) -> some View {
        content.padding(22).frame(maxWidth: .infinity, alignment: .leading)
            .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 26))
    }
}

extension View {
    func focusCard() -> some View { modifier(Card()) }
}

func countdown(_ seconds: TimeInterval) -> String {
    let total = Int(ceil(max(0, seconds)))
    return String(format: "%02d:%02d", total / 60, total % 60)
}
