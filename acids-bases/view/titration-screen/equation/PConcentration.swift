//
// Reactions App
//

import SwiftUI
import ReactionsCore

// See comment in TitrationEquationMolesToMolarity.swift
private typealias BoxWidthTextLine = TitrationEquationView.BoxWidthTextLine
private typealias Placeholder = TitrationEquationView.PlaceholderTermView
private typealias PlaceholderEquation = TitrationEquationView.PlaceholderEquationView

extension TitrationEquationView {
    struct PConcentrationDefinition: View {

        let data: TitrationEquationData
        let resultPValue: Term.Placeholder<Term.PValue>
        let pkValue: Term.Placeholder<Term.PValue>
        let numeratorConcentration: Term.Placeholder<Term.Concentration>
        let denominatorConcentration: Term.Placeholder<Term.Concentration>
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                BoxWidthTextLine(data: data, value: resultPValue)
                    .frame(width: layout.boxWidth)
                FixedText("=")
                BoxWidthTextLine(data: data, value: pkValue)
                FixedText("+")
                HStack(spacing: 0) {
                    FixedText("log")
                    FixedText("(")
                        .scaleEffect(y: layout.fractionParenHeightScaleFactor)

                    VStack(spacing: layout.fractionVSpacing) {
                        BoxWidthTextLine(data: data, value: numeratorConcentration)
                        Rectangle()
                            .frame(width: 80, height: layout.fractionBarHeight)
                        BoxWidthTextLine(data: data, value: denominatorConcentration)
                    }
                    .padding(.horizontal, 2)

                    FixedText(")")
                        .scaleEffect(y: layout.fractionParenHeightScaleFactor)
                }
            }
            .font(.system(size: layout.fontSize))
            .lineLimit(1)
            .minimumScaleFactor(layout.minScaleFactor)
        }
    }

    struct PConcentrationFilled: View {

        let data: TitrationEquationData
        let resultPValue: Term.Placeholder<Term.PValue>
        let pkValue: Term.Placeholder<Term.PValue>
        let numeratorConcentration: Term.Placeholder<Term.Concentration>
        let denominatorConcentration: Term.Placeholder<Term.Concentration>
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                PlaceholderEquation(data: data, value: resultPValue)
                    .frame(width: layout.boxWidth)
                FixedText("=")
                PlaceholderEquation(data: data, value: pkValue)
                FixedText("+")
                HStack(spacing: 0) {
                    FixedText("log")
                    FixedText("(")
                        .scaleEffect(y: layout.fractionParenHeightScaleFactor)
                    VStack(spacing: layout.fractionVSpacing) {
                        PlaceholderEquation(data: data, value: numeratorConcentration)
                        Rectangle()
                            .frame(width: 80, height: layout.fractionBarHeight)
                        PlaceholderEquation(data: data, value: denominatorConcentration)
                    }
                    FixedText(")")
                        .scaleEffect(y: layout.fractionParenHeightScaleFactor)
                }
            }
            .font(.system(size: layout.fontSize))
            .lineLimit(1)
            .minimumScaleFactor(layout.minScaleFactor)
        }
    }
}

struct TitrationEquationPConcentration_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TitrationEquationView.PConcentrationDefinition(
                data: .preview,
                resultPValue: .init(.hydrogen, isFilled: true),
                pkValue: .init(.kA, isFilled: true),
                numeratorConcentration: .init(.secondary, isFilled: true),
                denominatorConcentration: .init(.substance, isFilled: true)
            )

            TitrationEquationView.PConcentrationFilled(
                data: .preview,
                resultPValue: .init(.hydrogen, isFilled: false),
                pkValue: .init(.kA, isFilled: false),
                numeratorConcentration: .init(.secondary, isFilled: false),
                denominatorConcentration: .init(.substance, isFilled: false)
            )

            TitrationEquationView.PConcentrationFilled(
                data: .preview,
                resultPValue: .init(.hydrogen, isFilled: true),
                pkValue: .init(.kA, isFilled: true),
                numeratorConcentration: .init(.secondary, isFilled: true),
                denominatorConcentration: .init(.substance, isFilled: true)
            )
        }
        .previewLayout(.sizeThatFits)
    }
}
