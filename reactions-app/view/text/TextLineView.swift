//
// Reactions App
//
  

import SwiftUI

struct TextLinesView: View {

    let lines: [TextLine]
    let fontSize: CGFloat
    let subscriptFontSize: CGFloat
    let superscriptOffset: CGFloat
    let subscriptOffset: CGFloat

    init(
        lines: [TextLine],
        fontSize: CGFloat,
        subscriptFontSize: CGFloat,
        superscriptOffset: CGFloat,
        subscriptOffset: CGFloat
    ) {
        self.lines = lines
        self.fontSize = fontSize
        self.subscriptFontSize = subscriptFontSize
        self.superscriptOffset = superscriptOffset
        self.subscriptOffset = subscriptOffset
    }

    init(lines: [TextLine], fontSize: CGFloat) {
        self.init(
            lines: lines,
            fontSize: fontSize,
            subscriptFontSize: 0.65 * fontSize,
            superscriptOffset: 0.26 * fontSize,
            subscriptOffset: -0.26 * fontSize
        )
    }

    init(line: TextLine, fontSize: CGFloat) {
        self.init(lines: [line], fontSize: fontSize)
    }

    var body: some View {
        if let firstLine = lines.first {
            return lines.dropFirst().reduce(lineView(firstLine)) { acc, next in
                acc + Text("\n\n") + lineView(next)
            }
        }
        return Text("")
    }

    private func lineView(_ line: TextLine) -> Text {
        line.content.reduce(Text(""), {
            $0 + text($1)
        })
    }

    private func text(_ segment: TextSegment) -> Text {
        Text(segment.allowBreaks ? segment.content : Strings.withNoBreaks(str: segment.content))
            .foregroundColor(segment.emphasised ? .orangeAccent : .black)
            .font(.system(size: fontSize(line: segment)))
            .baselineOffset(fontOffset(line: segment))
    }

    private func fontSize(line: TextSegment) -> CGFloat {
        line.scriptType == nil ? fontSize : subscriptFontSize
    }

    private func fontOffset(line: TextSegment) -> CGFloat {
        switch (line.scriptType) {
        case .some(.superScript): return superscriptOffset
        case .some(.subScript): return subscriptOffset
        case .none: return 0
        }
    }
}
