//
// Reactions App
//
  

import SwiftUI

struct BeakyBox: View {

    let statement: [SpeechBubbleLine]
    let next: () -> Void
    let back: () -> Void
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
                SpeechBubble(lines: statement)
                    .frame(width: bubbleWidth, height: bubbleHeight)
                    .font(.system(size: fontSize))
                Beaky()
                    .frame(height: beakyHeight)
            }

            HStack {
                PreviousButton(action: back)
                    .frame(width: navButtonSize, height: navButtonSize)
                Spacer()
                NextButton(action: next)
                    .frame(width: navButtonSize, height: navButtonSize)
            }.frame(width: bubbleWidth - bubbleStemWidth)
        }
    }
}


