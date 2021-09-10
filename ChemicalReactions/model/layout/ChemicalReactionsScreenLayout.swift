//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct ChemicalReactionsScreenLayout {
    let geometry: GeometryProxy
    let verticalSizeClass: UserInterfaceSizeClass?
    let horizontalSizeClass: UserInterfaceSizeClass?

    var width: CGFloat {
        geometry.size.width
    }

    var height: CGFloat {
        geometry.size.height
    }

    static let topLevelScreenPadding: CGFloat = 10
}

// MARK: - Beaky
extension ChemicalReactionsScreenLayout {

    var beakyBoxHeight: CGFloat {
        0.35 * height
    }

    var beakyBoxWidth: CGFloat {
        0.33 * width
    }

    var beakySettings: BeakyGeometrySettings {
        BeakyGeometrySettings(
            width: beakyBoxWidth,
            height: beakyBoxHeight
        )
    }
}

// MARK: - Reaction selection
extension ChemicalReactionsScreenLayout {
    var reactionSelectionToggleHeight: CGFloat {
        0.05 * height
    }
}
