//
// Reactions App
//

import SwiftUI

struct BeakyBox: View {

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

    var body: some View {
        VStack(alignment: .leading, spacing: verticalSpacing) {
            HStack(alignment: .bottom, spacing: 0) {
                SpeechBubble(lines: statement, fontSize: fontSize)
                    .frame(width: bubbleWidth, height: bubbleHeight)
                    .accessibility(addTraits: .isHeader)
                    .accessibility(sortPriority: 1)
                    .accessibility(hint: Text("Goes to the next content"))
                    .accessibility(addTraits: .isButton)
                    .disabled(nextIsDisabled)
                    .accessibilityAction {
                        next()
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
                    .frame(width: nextButtonWidth, height: navButtonSize)
                    .accessibility(sortPriority: 0.9)
                    .disabled(nextIsDisabled)
                    .compositingGroup()
                    .opacity(nextIsDisabled ? 0.6 : 1)
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
                    OrderedReactionLayoutSettings(
                        geometry: geometry,
                        horizontalSize: nil,
                        verticalSize: nil
                    )
                )
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .previewLayout(.fixed(width: 568, height: 320))
    }

    private static func box(_ settings: OrderedReactionLayoutSettings) -> some View {
        BeakyBox(
            statement: ["Test statement"],
            next: { },
            back: { },
            nextIsDisabled: true,
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
