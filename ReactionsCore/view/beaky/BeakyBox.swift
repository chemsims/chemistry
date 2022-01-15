//
// Reactions App
//

import SwiftUI

public struct BeakyBox: View {

    let statement: [TextLine]
    let next: () -> Void
    let back: () -> Void
    let nextIsDisabled: Bool
    let verticalSpacing: CGFloat
    let bubbleWidth: CGFloat
    let bubbleHeight: CGFloat
    let beakyHeight: CGFloat
    let fontSize: CGFloat
    let navButtonSize: CGFloat
    let bubbleStemWidth: CGFloat

    public init(
        statement: [TextLine],
        next: @escaping () -> Void,
        back: @escaping () -> Void,
        nextIsDisabled: Bool,
        verticalSpacing: CGFloat,
        bubbleWidth: CGFloat,
        bubbleHeight: CGFloat,
        beakyHeight: CGFloat,
        fontSize: CGFloat,
        navButtonSize: CGFloat,
        bubbleStemWidth: CGFloat
    ) {
        self.statement = statement
        self.next = next
        self.back = back
        self.nextIsDisabled = nextIsDisabled
        self.verticalSpacing = verticalSpacing
        self.bubbleWidth = bubbleWidth
        self.bubbleHeight = bubbleHeight
        self.beakyHeight = beakyHeight
        self.fontSize = fontSize
        self.navButtonSize = navButtonSize
        self.bubbleStemWidth = bubbleStemWidth
    }

    public init(
        statement: [TextLine],
        next: @escaping () -> Void,
        back: @escaping () -> Void,
        nextIsDisabled: Bool,
        settings: BeakyGeometrySettings
    ) {
        self.init(
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

    public var body: some View {
        VStack(alignment: .leading, spacing: verticalSpacing) {
            HStack(alignment: .bottom, spacing: 0) {
                SpeechBubble(lines: statement, fontSize: fontSize)
                    .frame(width: bubbleWidth, height: bubbleHeight)
                    .accessibility(addTraits: .isHeader)
                    .accessibility(sortPriority: 1)
                    .accessibility(hint: Text("Double tap to go next"))
                    .accessibility(addTraits: .isButton)
                    .disabled(nextIsDisabled)
                    .accessibilityAction {
                        if !nextIsDisabled {
                            next()
                        }
                    }

                Beaky()
                    .frame(height: beakyHeight)
            }

            HStack {
                PreviousButton(action: back)
                    .frame(width: navButtonSize, height: navButtonSize)
                    .accessibility(sortPriority: 0.8)
                Spacer()
                PrimaryNextButton(action: next)
                    .disabled(nextIsDisabled)
                    .frame(width: nextButtonWidth, height: navButtonSize)
                    .accessibility(sortPriority: 0.9)
            }.frame(width: bubbleWidth - bubbleStemWidth)
        }
    }

    private var nextButtonWidth: CGFloat {
        let maxWidth = 0.9 * (bubbleWidth - bubbleStemWidth - navButtonSize)
        return min(maxWidth, 3.2 * navButtonSize)
    }
}


struct BeakyBox_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            ZStack {
                box(
                    BeakyGeometrySettings(
                        screenWidth: geometry.size.width,
                        screenHeight: geometry.size.height
                    )
                )
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .previewLayout(.fixed(width: 568, height: 320))

        box(
            BeakyGeometrySettings(
                width: 205,
                height: 148
            )
        )
        .previewLayout(.fixed(width: 568, height: 320))
        

    }

    private static func box(_ settings:  BeakyGeometrySettings) -> some View {
        BeakyBox(
            statement: ["Test statement"],
            next: { },
            back: { },
            nextIsDisabled: true,
            settings: settings
        )
    }
}
