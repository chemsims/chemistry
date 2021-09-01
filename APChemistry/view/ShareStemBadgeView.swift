//
// Reactions App
//

import ReactionsCore
import SwiftUI

struct ShareStemBadgeView: View {

    let onCompletion: () -> Void

    var body: some View {
        ShareSheetView(
            activityItems: [
                UIImage(named: "stem-badge") as Any,
                ShareSettings.message
            ],
            onCompletion: onCompletion
        )
        .edgesIgnoringSafeArea(.all)
    }
}
