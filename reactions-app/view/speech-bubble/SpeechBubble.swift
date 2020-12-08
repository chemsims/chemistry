//
// Reactions App
//


import SwiftUI

struct SpeechBubble: View {

    let lines: [SpeechBubbleLine]

    var body: some View {
        GeometryReader { geometry in
            SpeechBubbleWithSettings(
                lines: lines,
                settings: SpeechBubbleSettings(geometry: geometry)
            )
        }
    }
}

fileprivate struct SpeechBubbleWithSettings: View {

    let lines: [SpeechBubbleLine]
    let settings: SpeechBubbleSettings

    var body: some View {
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
            $0 + text($1)
        })
    }

    private func text(_ segment: SpeechBubbleLineSegment) -> Text {
        Text(segment.content)
            .foregroundColor(segment.emphasised ? .orangeAccent : .black)
            .font(.system(size: fontSize(line: segment)))
            .baselineOffset(fontOffset(line: segment))
    }

    private func fontSize(line: SpeechBubbleLineSegment) -> CGFloat {
        line.scriptType == nil ? settings.fontSize : settings.subscriptFontSize
    }

    private func fontOffset(line: SpeechBubbleLineSegment) -> CGFloat {
        switch (line.scriptType) {
        case .some(.superScript): return settings.superscriptOffset
        case .some(.subScript): return settings.subscriptOffset
        case .none: return 0
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

    var fontSize: CGFloat {
        0.09 * geometry.size.height
    }

    var subscriptFontSize: CGFloat {
        0.65 * fontSize
    }

    var subscriptOffset: CGFloat {
        -1 * superscriptOffset
    }

    var superscriptOffset: CGFloat {
        0.6 * subscriptFontSize
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
            .init(content: "too elor it!A", emphasised: false),
            .init(content: "0", emphasised: false, scriptType: .superScript),
            .init(content: " != A", emphasised: false),
            .init(content: "123", emphasised: false, scriptType: .subScript),
        ])
    ]


    static var previews: some View {
        SpeechBubble(lines: lines).frame(width: 220, height: 200)
    }
}
