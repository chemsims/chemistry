//
// Reactions App
//


import SwiftUI

struct SpeechBubble: View {

    let lines: [SpeechBubbleLine]

    var body: some View {
        GeometryReader { geometry in
            makeView(with: SpeechBubbleSettings(geometry: geometry))
        }
    }

    private func makeView(with settings: SpeechBubbleSettings) -> some View {
        Group {
            RoundedRectangle(cornerRadius: settings.cornerRadius)
                .fill(Styling.speechBubble)
                .frame(width: settings.bubbleWidth)

            SpeechBubbleStem(cornerRadius: settings.stemCornerRadius)
                .fill(Styling.speechBubble)
                .frame(width: settings.stemWidth, height: settings.stemHeight)
                .offset(x: settings.bubbleWidth, y: settings.stemYOffset)

            linesView
                .padding(settings.bubbleTextPadding)
                .frame(width: settings.bubbleWidth, height: settings.geometry.size.height)
        }.minimumScaleFactor(0.6)
    }

    private var linesView: Text {
        if let firstLine = lines.first {
            return lines.dropFirst().reduce(lineView(firstLine)) { acc, next in
                acc + Text("\n\n") + lineView(next)
            }
        }
        return Text("")
    }

    private func lineView(_ line: SpeechBubbleLine) -> Text {
        line.content.reduce(Text(""), {
            $0 + Text($1.content)
                    .foregroundColor($1.emphasised ? .orangeAccent : .black)
        })
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

struct SpeechBubbleSettings {
    let geometry: GeometryProxy

    static func getStemWidth(width: CGFloat) -> CGFloat {
        width * 0.2
    }

    var stemWidth: CGFloat {
        SpeechBubbleSettings.getStemWidth(width: geometry.size.width)
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
        let bottomOfStemToTopOfBubble: CGFloat = 0.83
        let dy = (geometry.size.height * bottomOfStemToTopOfBubble) - stemHeight
        return max(dy, 0)
    }

    var stemCornerRadius: CGFloat {
        stemWidth * 0.3
    }

    var bubbleTextPadding: CGFloat {
        let minDimension: CGFloat = min(geometry.size.width, geometry.size.height)
        return minDimension * 0.06
    }
}

struct SpeechBubble_Previews: PreviewProvider {

    static let lines = [
        SpeechBubbleLine(content: [
            .init(content: "Hey there, fellow student!", emphasised: false)
        ]),
        SpeechBubbleLine(content: [
            .init(content: "Choose a reaction ", emphasised: true),
            .init(content: "to explore it!", emphasised: false)
        ])
    ]


    static var previews: some View {
        SpeechBubble(lines: lines).frame(width: 220, height: 200)
    }
}
