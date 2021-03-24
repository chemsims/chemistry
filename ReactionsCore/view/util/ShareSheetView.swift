//
// Reactions App
//

import SwiftUI

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

struct ShareSheetView: UIViewControllerRepresentable {

    let activityItems: [Any]

    func makeUIViewController(context: Context) -> some UIViewController {
        UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}

struct ShareSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ShareSheetView(activityItems: ["String to share"])
    }
}
