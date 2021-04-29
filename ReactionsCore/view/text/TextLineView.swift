//
// Reactions App
//

import SwiftUI

public struct TextLinesView: View {

    let lines: [TextLine]
    let fontSize: CGFloat
    let subscriptFontSize: CGFloat
    let superscriptOffset: CGFloat
    let subscriptOffset: CGFloat
    let weight: Font.Weight
    let color: Color

    public init(
        lines: [TextLine],
        fontSize: CGFloat,
        subscriptFontSize: CGFloat,
        superscriptOffset: CGFloat,
        subscriptOffset: CGFloat,
        weight: Font.Weight,
        color: Color
    ) {
        self.lines = lines
        self.fontSize = fontSize
        self.subscriptFontSize = subscriptFontSize
        self.superscriptOffset = superscriptOffset
        self.subscriptOffset = subscriptOffset
        self.weight = weight
        self.color = color
    }

    public init(
        lines: [TextLine],
        fontSize: CGFloat,
        weight: Font.Weight = .regular,
        color: Color = .black
    ) {
        self.init(
            lines: lines,
            fontSize: fontSize,
            subscriptFontSize: 0.65 * fontSize,
            superscriptOffset: 0.26 * fontSize,
            subscriptOffset: -0.26 * fontSize,
            weight: weight,
            color: color
        )
    }

    public init(
        line: TextLine,
        fontSize: CGFloat,
        weight: Font.Weight = .regular,
        color: Color = .black
    ) {
        self.init(lines: [line], fontSize: fontSize, weight: weight, color: color)
    }

    public var body: some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibility(label: Text(label))
    }

    private var content: some View {
        if let firstLine = lines.first {
            return lines.dropFirst().reduce(lineView(firstLine)) { acc, next in
                acc + Text("\n\n") + lineView(next)
            }
        }
        return Text("")
    }

    private var label: String {
        lines.label
    }

    private func lineView(_ line: TextLine) -> Text {
        line.content.reduce(Text(""), {
            $0 + text($1)
        })
    }

    private func text(_ segment: TextSegment) -> Text {
        Text(segment.allowBreaks ? segment.content : Strings.withNoBreaks(str: segment.content))
            .foregroundColor(segment.emphasised ? .orangeAccent : color)
            .font(.system(size: fontSize(line: segment), weight: weight))
            .baselineOffset(fontOffset(line: segment))
            .italic(enabled: segment.italic)
    }

    private func fontSize(line: TextSegment) -> CGFloat {
        line.scriptType == nil ? fontSize : subscriptFontSize
    }

    private func fontOffset(line: TextSegment) -> CGFloat {
        switch line.scriptType {
        case .some(.superScript): return superscriptOffset
        case .some(.subScript): return subscriptOffset
        case .none: return 0
        }
    }
}

extension Text {
    func italic(enabled: Bool) -> Text {
        if enabled {
            return self.italic()
        }
        return self
    }
}
