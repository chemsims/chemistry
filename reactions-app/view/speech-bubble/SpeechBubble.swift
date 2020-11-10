//
// Reactions App
//


import SwiftUI

struct SpeechBubble: View {

    var body: some View {
        GeometryReader { geometry in
            makeView(with: SpeechBubbleSettings(geometry: geometry))
        }
    }

    private func makeView(with settings: SpeechBubbleSettings) -> some View {
        Group {
            RoundedRectangle(cornerRadius: settings.cornerRadius)
                .fill(Color.mediumGray)
                .frame(width: settings.bubbleWidth)

            SpeechBubbleStem(cornerRadius: settings.stemCornerRadius)
                .fill(Color.mediumGray)
                .frame(width: settings.stemWidth, height: settings.stemHeight)
                .offset(x: settings.bubbleWidth, y: settings.stemYOffset)
        }
    }

}

struct SpeechBubbleStem: Shape {

    let cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let bottomLeft = CGPoint(x: 0, y: rect.height)
        let topRight = CGPoint(x: rect.width, y: cornerRadius)
        let topPreCurve = CGPoint(x: cornerRadius, y: cornerRadius)

        path.addLines([bottomLeft, topRight, topPreCurve])

        let control = CGPoint(x: 0, y: cornerRadius)
        path.addQuadCurve(to: .zero, control: control)
        return path
    }
}

private struct SpeechBubbleSettings {
    let geometry: GeometryProxy

    var stemWidth: CGFloat {
        geometry.size.width * 0.2
    }

    var stemHeight: CGFloat {
        stemWidth * 1.1
    }

    var cornerRadius: CGFloat {
        geometry.size.width * 0.1
    }

    var bubbleWidth: CGFloat {
        geometry.size.width - stemWidth
    }

    var stemYOffset: CGFloat {
        let bottomOfStemToTopOfBubble: CGFloat = 0.85
        let dy = (geometry.size.height * bottomOfStemToTopOfBubble) - stemHeight
        return max(dy, 0)
    }

    var stemCornerRadius: CGFloat {
        stemWidth * 0.3
    }
}

struct SpeechBubble_Previews: PreviewProvider {
    static var previews: some View {
        SpeechBubble().frame(width: 200, height: 200)
    }
}
