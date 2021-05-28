//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AcidBasesGeneralScreenLayout {
    let geometry: GeometryProxy
    let verticalSizeClass: UserInterfaceSizeClass?
    let horizontalSizeClass: UserInterfaceSizeClass?

    var width: CGFloat {
        geometry.size.width
    }

    var height: CGFloat {
        geometry.size.height
    }

    var leftColumnWidth: CGFloat {
        0.33 * width
    }

    var rightColumnWidth: CGFloat {
        width - leftColumnWidth
    }

    var beakyBoxWidth: CGFloat {
        rightColumnWidth / 2
    }

    var beakyBoxHeight: CGFloat {
        0.35 * height
    }

    var chartColumnWidth: CGFloat {
        rightColumnWidth - beakyBoxWidth
    }

    var beakySettings: BeakyGeometrySettings {
        BeakyGeometrySettings(
            width: beakyBoxWidth,
            height: beakyBoxHeight
        )
    }




}
