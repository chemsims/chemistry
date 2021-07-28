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
