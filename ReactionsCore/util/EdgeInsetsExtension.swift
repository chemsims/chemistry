//
// Reactions App
//

import SwiftUI

extension EdgeInsets {

    /// Returns an `EdgeInsets` instance with a default value of 0 for each edge
    public static func withDefaults(
        top: CGFloat = 0,
        leading: CGFloat = 0,
        bottom: CGFloat = 0,
        trailing: CGFloat = 0
    ) -> EdgeInsets {
        EdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing)
    }
}
