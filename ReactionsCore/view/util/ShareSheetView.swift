//
// Reactions App
//

import SwiftUI

struct ShareSheetView: UIViewControllerRepresentable {

    let activityItems: [Any]
    let onCompletion: () -> Void

    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        controller.completionWithItemsHandler = { _, _, _, _ in
            onCompletion()
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}

public struct ShareSettings {
    let message: String

    public init(
        appStoreUrl: String,
        appName: String
    ) {
        self.message = """
        Hey, check out the \(appName) app! Download it at \(appStoreUrl).
        """
    }
}

struct ShareSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ShareSheetView(activityItems: ["String to share"], onCompletion: {})
    }
}
