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

public struct ShareSettings {
    let message: String
    let appStoreUrl = ""

    public init() {
        let url = "https://apps.apple.com/us/app/ap-chemistry-reactions/id1531309001"
        self.message = """
        Hey, check out this great AP Chemistry app! Download it at \(url).
        """
    }
}

struct ShareSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ShareSheetView(activityItems: ["String to share"], onCompletion: {})
    }
}
