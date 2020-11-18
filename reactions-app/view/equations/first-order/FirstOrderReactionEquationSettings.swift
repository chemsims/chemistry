//
// Reactions App
//
  

import SwiftUI

struct FirstOrderEquationSettings {
    let maxWidth: CGFloat
    let maxHeight: CGFloat

    var width: CGFloat {
        maxWidth
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
        0.09 * width
    }

    var subscriptFontSize: CGFloat {
        fontSize * 0.7
    }

    var subscriptBaselineOffset: CGFloat {
        fontSize * -0.4
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
    var boxSize: CGFloat {
        0.15 * width
    }

    func termOrBox(_ t: String?) -> some View {
        if (t != nil) {
            return AnyView(
                Text(t!)
            )
        }
        return AnyView(
            EquationPlaceholderView()
                .padding(0.1 * boxSize)
                .frame(width: boxSize, height: boxSize)
        )
    }
}
