//
// Reactions App
//

import SwiftUI

public struct ShareSheetView: UIViewControllerRepresentable {

    public init(
        activityItems: [Any],
        onCompletion: @escaping () -> Void
    ) {
        self.activityItems = activityItems
        self.onCompletion = onCompletion
    }

    let activityItems: [Any]
    let onCompletion: () -> Void

    public func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        controller.completionWithItemsHandler = { _, _, _, _ in
            onCompletion()
        }
        return controller
    }

    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}

// TODO - no need to pass an instance of this around anymore, can just use
// static var for the message
public struct ShareSettings {
    public let message: String

    public init() {
        self.message = Self.message
    }

    public static let url = "https://apps.apple.com/app/id1531309001"

    public static let message = """
    Hey, check out ChemSims, a great app to learn chemistry using interactive simulations! Download it at \(url).
    """
}

struct ShareSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ShareSheetView(activityItems: ["String to share"], onCompletion: {})
    }
}
