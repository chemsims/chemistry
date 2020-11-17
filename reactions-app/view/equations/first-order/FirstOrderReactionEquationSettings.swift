//
// Reactions App
//
  

import SwiftUI

struct FirstOrderEquationSettings {
    let geometry: GeometryProxy

    var width: CGFloat {
        min(2.4 * geometry.size.height, geometry.size.width)
    }

    var rateSize: CGFloat {
        0.2 * width
    }

    var equalsWidth: CGFloat {
        0.07 * width
    }

    var negativeWidth: CGFloat {
        0.07 * width
    }

    var fontSize: CGFloat {
        0.11 * width
    }

    var hStackSpacing: CGFloat {
        0.02 * width
    }

    var term1Width: CGFloat {
        0.25 * width
    }

    var term1Height: CGFloat {
        0.2 * width
    }

    var rateDividerWidth:CGFloat {
        0.6 * width
    }

    func termOrBox(_ t: String?) -> some View {
        if (t != nil) {
            return AnyView(
                Text(t!)
            )
        }
        return AnyView(
            EquationPlaceholderView()
                .padding(0.1 * term1Width)
        )
    }
}
