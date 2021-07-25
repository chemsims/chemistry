//
// Reactions App
//


import SwiftUI

extension View {
    func notification(
        _ notification: NotificationViewModel.Notification?
    ) -> some View {
        self.modifier(
            NotificationOverlayModifier(
                notification: notification
            )
        )
    }
}

private struct NotificationOverlayModifier: ViewModifier {

    let notification: NotificationViewModel.Notification?

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content

            if notification != nil {
                NotificationCard(notification: notification!)
                    .id(notification?.id)
                    .transition(.move(edge: .top))
                    .animation(
                        .easeOut(duration: NotificationViewModel.animationDuration)
                    )
                    .zIndex(99)
            }
        }
    }
}

struct NotificationOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        ViewWrapper()
    }

    private struct ViewWrapper: View {
        @ObservedObject var model = NotificationViewModel.shared

        var body: some View {
            VStack {
                Rectangle()
                    .foregroundColor(.red)
                    .onTapGesture {
                        model.showNotification(
                            .init(message: "Success",
                                  icon: .tick
                            )
                        )
                    }

                Circle()
                    .onTapGesture {
                        model.showNotification(
                            .init(message: "Error",
                                  icon: .error
                            )
                        )
                    }
                    .foregroundColor(.purple)
            }
            .notification(model.notification)
        }
    }
}
