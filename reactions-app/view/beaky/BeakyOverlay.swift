//
// Reactions App
//
  

import SwiftUI

struct BeakyOverlay: View {

    let statement: [TextLine]
    let next: () -> Void
    let back: () -> Void
    let nextIsDisabled: Bool
    let settings: OrderedReactionLayoutSettings

    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                BeakyBox(
                    statement: statement,
                    next: next,
                    back: back,
                    nextIsDisabled: nextIsDisabled,
                    verticalSpacing: settings.beakyVSpacing,
                    bubbleWidth: settings.bubbleWidth,
                    bubbleHeight: settings.bubbleHeight,
                    beakyHeight: settings.beakyHeight,
                    fontSize: settings.bubbleFontSize,
                    navButtonSize: settings.navButtonSize,
                    bubbleStemWidth: settings.bubbleStemWidth
                )
            }
        }
    }
}
