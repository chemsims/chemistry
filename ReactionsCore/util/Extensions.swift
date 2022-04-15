//
// Reactions App
//

import SwiftUI
import CoreMotion

extension View {

    /// Adds `value` as a label of the view, after passing it through the labelling function
    /// to generate a nicer label.
    public func accessibilityParsedLabel(_ value: String) -> some View {
        self.accessibility(label: Text(Labelling.stringToLabel(value)))
    }
}

extension CGFloat {
    /// Dissociation constant of water (Kw) at 25°C
    public static let waterDissociationConstant: CGFloat = 1e-14
}

extension CMRotationRate {
    var magnitude: Double {
        sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2))
    }
}
