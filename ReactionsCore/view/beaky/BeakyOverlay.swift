//
// Reactions App
//

import SwiftUI

public struct BeakyOverlay: View {

    let statement: [TextLine]
    let next: () -> Void
    let back: () -> Void
    let nextIsDisabled: Bool
    let settings: BeakyGeometrySettings

    public init(
        statement: [TextLine],
        next: @escaping () -> Void,
        back: @escaping () -> Void,
        nextIsDisabled: Bool,
        settings: BeakyGeometrySettings
    ) {
        self.statement = statement
        self.next = next
        self.back = back
        self.nextIsDisabled = nextIsDisabled
        self.settings = settings
    }

    public var body: some View {
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



