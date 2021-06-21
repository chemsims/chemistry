//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct TitrationLayoutEnvironmentKey: EnvironmentKey {
    static var defaultValue: TitrationEquationLayout = .init()
}

extension EnvironmentValues {
    var titrationEquationLayout: TitrationEquationLayout {
        get { self[TitrationLayoutEnvironmentKey.self] }
        set { self[TitrationLayoutEnvironmentKey.self] = newValue }
    }
}

extension TitrationEquationView {

    static func defaultFormatter(_ value: CGFloat) -> TextLine {
        TextLine(value.str(decimals: 2))
    }

    struct BoxWidthTextLine<Label : TitrationEquationLabel>: View {
        let data: TitrationEquationData
        let value: Label
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            TextLinesView(line: value.label(forData: data), fontSize: layout.fontSize)
                .frame(width: layout.boxWidth)
        }
    }

    struct PlaceholderTermView<Label : TitrationEquationValue>: View {
        let data: TitrationEquationData
        let value: Term.Placeholder<Label>
        let formatter: (CGFloat) -> TextLine

        init(
            data: TitrationEquationData,
            value: Term.Placeholder<Label>,
            formatter: @escaping (CGFloat) -> TextLine = defaultFormatter
        ) {
            self.data = data
            self.value = value
            self.formatter = formatter
        }

        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            PlaceholderTextLine(
                value: value.isFilled ? formatter(value.term.value(forData: data)) : nil
            )
        }
    }
}
