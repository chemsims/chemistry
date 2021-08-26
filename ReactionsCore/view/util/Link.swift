//
// Reactions App
//


import SwiftUI

/// Provides a link using either a button, or a `Link` type, depending on the OS version
public struct LegacyLink<Label: View>: View {

    public init(destination: URL, label: @escaping () -> Label) {
        self.destination = destination
        self.label = label
    }

    let destination: URL
    @ViewBuilder var label: () -> Label

    @ViewBuilder
    public var body: some View {
        if #available(iOS 14.0, *) {
            Link(
                destination: destination,
                label: label
            )
        } else {
            Button(
                action: {
                    UIApplication.shared.open(destination)
                },
                label: label
            )
        }
    }
}

struct Link_Previews: PreviewProvider {
    static var previews: some View {
        LegacyLink(
            destination: URL(string: "https://www.apple.com")!
        ) {
            Text("Apple")
        }
    }
}
