//
// Reactions App
//

import SwiftUI

extension View {
    @ViewBuilder
    public func modifyIf<T: View>(_ condition: Bool, apply: (Self) -> T) -> some View {
        if condition {
            apply(self)
        } else {
            self
        }
    }
}
