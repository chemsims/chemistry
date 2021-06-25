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
        TextLineUtil.scientific(value: value, threshold: 0.01).emphasised()
    }

    struct BoxWidthTextLine<Label : TitrationEquationTermLabel>: View {
        let data: TitrationEquationData
        let value: Label
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            TitrationEquationView.PlainLine(line: value.label(forData: data))
                .frame(width: layout.boxWidth)
        }
    }

    struct PlaceholderTermView<Label : TitrationEquationTermValue>: View {
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
            .frame(width: layout.boxWidth)
        }
    }

    struct PlaceholderEquationView<Label : TitrationEquationTermEquation>: View {
        let data: TitrationEquationData
        let value: Term.Placeholder<Label>
        let equationInput: CGFloat
        let formatter: (CGFloat) -> TextLine
        @Environment(\.titrationEquationLayout) var layout

        init(
            data: TitrationEquationData,
            value: Term.Placeholder<Label>,
            equationInput: CGFloat,
            formatter: @escaping (CGFloat) -> TextLine = defaultFormatter
        ) {
            self.data = data
            self.value = value
            self.equationInput = equationInput
            self.formatter = formatter
        }

        var body: some View {
            if value.isFilled {
                AnimatingTextLine(
                    x: equationInput,
                    equation: value.term.equation(forData: data),
                    fontSize: layout.fontSize,
                    formatter: formatter
                )
                .frame(width: layout.boxWidth, height: layout.boxHeight)
            } else {
                PlaceholderTerm(value: nil)
                    .frame(width: layout.boxWidth, height: layout.boxHeight)
            }
        }
    }

    struct PlainLine: View {
        let line: TextLine
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            TextLinesView(line: line, fontSize: layout.fontSize)
        }
    }

    struct BoxWidthTermOrPlaceholder<Label : TitrationEquationTermLabel & TitrationEquationTermValue>: View {

        let data: TitrationEquationData
        let value: Term.Placeholder<Label>
        let showDefinition: Bool

        @ViewBuilder
        var body: some View {
            if showDefinition {
                TitrationEquationView.BoxWidthTextLine(data: data, value: value.term)
            } else {
                TitrationEquationView.PlaceholderTermView(data: data, value: value)
            }
        }
    }
}
