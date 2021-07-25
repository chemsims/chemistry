//
// Reactions App
//


import SwiftUI

struct NotificationCard: View {

    let message: String
    let icon: Icon

    private static let iconPadding: CGFloat = -6

    var body: some View {
        Text(message)
            .padding()
            .background(background)
            .overlay(iconView, alignment: .topTrailing)
            .padding(.top, -2 * Self.iconPadding)
    }

    private var background: some View {
        RoundedRectangle(cornerRadius: 10)
            .foregroundColor(.white)
            .shadow(radius: 4)
    }

    private var iconView: some View {
        Image(systemName: icon.imageName)
            .foregroundColor(icon.color)
            .padding(Self.iconPadding)
            .font(.system(.body).weight(.bold))
    }

    enum Icon {
        case tick, error

        fileprivate var imageName: String {
            switch self {
            case .tick: return "checkmark.circle"
            case .error: return "exclamationmark.triangle"
            }
        }

        fileprivate var color: Color {
            switch self {
            case .tick: return .green
            case .error: return .red
            }
        }
    }
}

extension NotificationCard {
    init(notification: NotificationViewModel.Notification) {
        self.init(
            message: notification.message,
            icon: notification.icon
        )
    }
}

struct NotificationCard_Previews: PreviewProvider {
    static var previews: some View {
        NotificationCard(
            message: "Purchase successful",
            icon: .tick
        )
    }
}
