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
        TextLine(value.str(decimals: 2)).emphasised()
    }

    struct BoxWidthTextLine<Label : TitrationEquationLabel>: View {
        let data: TitrationEquationData
        let value: Label
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            PlainLine(line: value.label(forData: data))
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

    struct PlainLine: View {
        let line: TextLine
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            TextLinesView(line: line, fontSize: layout.fontSize)
        }
    }

    struct BoxWidthTermOrPlaceholder<Label : TitrationEquationLabel & TitrationEquationValue>: View {

        let data: TitrationEquationData
        let value: Term.Placeholder<Label>
        let showDefinition: Bool

        @ViewBuilder
        var body: some View {
            if showDefinition {
                BoxWidthTextLine(data: data, value: value.term)
            } else {
                PlaceholderTermView(data: data, value: value)
            }
        }
    }
}
