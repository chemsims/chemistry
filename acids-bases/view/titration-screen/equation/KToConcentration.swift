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
                FixedText("=")
                VStack(spacing: layout.fractionVSpacing) {
                    HStack(spacing: 5) {
                        PlainLine(
                            line: firstNumeratorConcentration.term.label(
                                forData: data
                            )
                        )
                        PlainLine(
                            line: secondNumeratorConcentration.term.label(
                                forData: data
                            )
                        )
                    }
                    Rectangle()
                        .frame(width: 130, height: layout.fractionBarHeight)
                    PlainLine(
                        line: denominatorConcentration.term.label(
                            forData: data
                        )
                    )
                }
            }
            .font(.system(size: layout.fontSize))
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
                FixedText("=")
                VStack(spacing: layout.fractionVSpacing) {
                    HStack(spacing: 5) {
                        FixedText("(")
                        PlaceholderEquation(data: data, value: firstNumeratorConcentration)
                        FixedText(")(")
                        PlaceholderEquation(data: data, value: secondNumeratorConcentration)
                        FixedText(")")
                    }
                    Rectangle()
                        .frame(width: divisorWidth, height: layout.fractionBarHeight)
                    PlaceholderEquation(data: data, value: denominatorConcentration)
                }
            }
            .font(.system(size: layout.fontSize))
        }

        private var divisorWidth: CGFloat {
            let numer1Width = layout.boxWidth(
                forFormatter: firstNumeratorConcentration.formatter
            )
            let numer2Width = layout.boxWidth(forFormatter: secondNumeratorConcentration.formatter
            )

            return numer1Width + numer2Width + 5
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
