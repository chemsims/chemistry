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

    public var body: some View {
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
                NextButton(action: next)
                    .frame(width: navButtonSize, height: navButtonSize)
                    .accessibility(sortPriority: 0.9)
                    .disabled(nextIsDisabled)
            }.frame(width: bubbleWidth - bubbleStemWidth)
        }
    }
}
