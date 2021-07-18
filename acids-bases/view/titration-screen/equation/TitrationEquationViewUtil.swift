//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct TitrationLayoutEnvironmentKey: EnvironmentKey {
    static var defaultValue: TitrationEquationLayout = .init()
}

struct TitrationEquationInput: EnvironmentKey {
    static var defaultValue: CGFloat? = nil
}

extension EnvironmentValues {
    var titrationEquationLayout: TitrationEquationLayout {
        get { self[TitrationLayoutEnvironmentKey.self] }
        set { self[TitrationLayoutEnvironmentKey.self] = newValue }
    }

    var titrationEquationInput: CGFloat? {
        get { self[TitrationEquationInput.self] }
        set { self[TitrationEquationInput.self] = newValue }
    }
}

extension TitrationEquationView {

    static func defaultFormatter(_ value: CGFloat) -> TextLine {
        TextLineUtil.scientific(value: value, threshold: 0.01).emphasised()
    }

    struct BoxWidthTextLine<Label : TitrationEquationTermLabel>: View {

        let data: TitrationEquationData
        let value: Term.Placeholder<Label>
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            TitrationEquationView.PlainLine(
                line: value.term.label(forData: data)
            )
            .frame(width: layout.boxWidth(forFormatter: value.formatter))
        }
    }

    struct PlaceholderTermView<Label : TitrationEquationTermValue & TitrationEquationTermLabel>: View {
        let data: TitrationEquationData
        let value: Term.Placeholder<Label>
        let formatter: (CGFloat) -> TextLine
        @Environment(\.titrationEquationLayout) var layout

        init(
            data: TitrationEquationData,
            value: Term.Placeholder<Label>,
            formatter: @escaping (CGFloat) -> TextLine = defaultFormatter
        ) {
            self.data = data
            self.value = value
            self.formatter = formatter
        }

        var body: some View {
            PlaceholderTextLine(
                value: value.isFilled ? formatter(value.term.value(forData: data)) : nil,
                fontSize: layout.fontSize,
                expandedWidth: layout.boxWidth(forFormatter: value.formatter)
            )
            .frame(
                width: layout.boxWidth(forFormatter: value.formatter),
                height: layout.boxHeight
            )
            .accessibility(label: Text(value.term.label(forData: data).label))
        }
    }

    struct PlaceholderEquationView<Label : TitrationEquationTermEquation & TitrationEquationTermLabel>: View {
        let data: TitrationEquationData
        let value: Term.Placeholder<Label>
        @Environment(\.titrationEquationInput) var equationInput
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            Group {
                if value.isFilled {
                    AnimatingTextLine(
                        x: equationInput ?? 0,
                        equation: value.term.equation(forData: data),
                        fontSize: layout.fontSize,
                        formatter: { v in
                            value.formatter.format(v).emphasised()
                        }
                    )
                    .frame(
                        width: layout.boxWidth(forFormatter: value.formatter),
                        height: layout.boxHeight
                    )
                } else {
                    PlaceholderTerm(value: nil)
                        .frame(
                            width: layout.boxWidth(forFormatter: value.formatter),
                            height: layout.boxHeight
                        )
                }
            }
            .accessibility(label: Text(value.term.label(forData: data).label))
        }
    }

    struct PlainLine: View {
        let line: TextLine
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            TextLinesView(line: line, fontSize: layout.fontSize)
                .fixedSize()
        }
    }

    struct BoxWidthTermOrPlaceholder<Label : TitrationEquationTermLabel & TitrationEquationTermValue>: View {

        let data: TitrationEquationData
        let value: Term.Placeholder<Label>
        let showDefinition: Bool

        @ViewBuilder
        var body: some View {
            if showDefinition {
                TitrationEquationView.BoxWidthTextLine(data: data, value: value)
            } else {
                TitrationEquationView.PlaceholderTermView(data: data, value: value)
            }
        }
    }
}
