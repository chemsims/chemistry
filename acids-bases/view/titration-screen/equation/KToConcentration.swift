//
// Reactions App
//

import SwiftUI
import ReactionsCore

// See comment in TitrationEquationMolesToMolarity.swift
private typealias BoxWidthTextLine = TitrationEquationView.BoxWidthTextLine
private typealias PlainLine = TitrationEquationView.PlainLine
private typealias Placeholder = TitrationEquationView.PlaceholderTermView
private typealias PlaceholderEquation = TitrationEquationView.PlaceholderEquationView

extension TitrationEquationView {
    struct KToConcentrationDefinition: View {

        let data: TitrationEquationData
        let kValue: Term.Placeholder<Term.KValue>
        let firstNumeratorConcentration: Term.Placeholder<Term.Concentration>
        let secondNumeratorConcentration: Term.Placeholder<Term.Concentration>
        let denominatorConcentration: Term.Placeholder<Term.Concentration>
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                BoxWidthTextLine(data: data, value: kValue)
                    .accessibility(sortPriority: 10)

                FixedText("=")
                    .accessibility(sortPriority: 9)

                VStack(spacing: layout.fractionVSpacing) {
                    HStack(spacing: 5) {
                        PlainLine(line: firstNumeratorLabel)
                        PlainLine(line: secondNumeratorLabel)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibility(label: Text("\(firstNumeratorLabel.label) times \(secondNumeratorLabel.label)"))
                    .accessibility(sortPriority: 8)

                    Rectangle()
                        .frame(width: 130, height: layout.fractionBarHeight)
                        .accessibility(label: Text("divide by"))
                        .accessibility(sortPriority: 7)

                    PlainLine(
                        line: denominatorConcentration.term.label(
                            forData: data
                        )
                    )
                    .accessibility(sortPriority: 6)
                }
            }
            .font(.system(size: layout.fontSize))
            .accessibilityElement(children: .combine)
            .accessibility(sortPriority: 0)
        }

        private var firstNumeratorLabel: TextLine {
            firstNumeratorConcentration.term.label(forData: data)
        }

        private var secondNumeratorLabel: TextLine {
            secondNumeratorConcentration.term.label(forData: data)
        }

    }

    struct KToConcentrationFilled: View {

        let data: TitrationEquationData
        let kValue: Term.Placeholder<Term.KValue>
        let firstNumeratorConcentration: Term.Placeholder<Term.Concentration>
        let secondNumeratorConcentration: Term.Placeholder<Term.Concentration>
        let denominatorConcentration: Term.Placeholder<Term.Concentration>
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                Placeholder(data: data, value: kValue)
                    .accessibility(sortPriority: 10)

                FixedText("=")
                    .accessibility(sortPriority: 9)

                VStack(spacing: layout.fractionVSpacing) {
                    HStack(spacing: 5) {
                        FixedText("(")
                            .accessibility(hidden: true)

                        PlaceholderEquation(data: data, value: firstNumeratorConcentration)
                            .accessibility(sortPriority: 8)

                        FixedText(")(")
                            .accessibility(hidden: true)

                        PlaceholderEquation(data: data, value: secondNumeratorConcentration)
                            .accessibility(sortPriority: 7)

                        FixedText(")")
                            .accessibility(hidden: true)
                    }
                    Rectangle()
                        .frame(width: divisorWidth, height: layout.fractionBarHeight)
                        .accessibility(label: Text("divide by"))
                        .accessibility(sortPriority: 6)

                    PlaceholderEquation(data: data, value: denominatorConcentration)
                        .accessibility(sortPriority: 5)
                }
            }
            .font(.system(size: layout.fontSize))
            .accessibilityElement(children: .contain)
        }

        private var divisorWidth: CGFloat {
            let numer1Width = layout.boxWidth(
                forFormatter: firstNumeratorConcentration.formatter
            )
            let numer2Width = layout.boxWidth(forFormatter: secondNumeratorConcentration.formatter
            )

            return numer1Width + numer2Width + 12
        }
    }
}

struct TitrationEquationKToConcentration_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TitrationEquationView.KToConcentrationDefinition(
                data: .preview,
                kValue: .init(.kA, isFilled: true),
                firstNumeratorConcentration: .init(.hydrogen, isFilled: true),
                secondNumeratorConcentration: .init(.secondary, isFilled: true),
                denominatorConcentration: .init(.substance, isFilled: true)
            )

            TitrationEquationView.KToConcentrationFilled(
                data: .preview,
                kValue: .init(.kA, isFilled: false),
                firstNumeratorConcentration: .init(.hydrogen, isFilled: false),
                secondNumeratorConcentration: .init(.secondary, isFilled: false),
                denominatorConcentration: .init(.substance, isFilled: false)
            )

            TitrationEquationView.KToConcentrationFilled(
                data: .preview,
                kValue: .init(.kA, isFilled: false),
                firstNumeratorConcentration: .init(.hydrogen, isFilled: true),
                secondNumeratorConcentration: .init(.secondary, isFilled: true),
                denominatorConcentration: .init(.substance, isFilled: true)
            )
        }
        .previewLayout(.sizeThatFits)
    }
}
