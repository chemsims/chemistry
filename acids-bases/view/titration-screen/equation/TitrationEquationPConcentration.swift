//
// Reactions App
//

import SwiftUI
import ReactionsCore

// See comment in TitrationEquationMolesToMolarity.swift
private typealias BoxWidthTextLine = TitrationEquationView.BoxWidthTextLine
private typealias Placeholder = TitrationEquationView.PlaceholderTermView

extension TitrationEquationView {
    struct PConcentrationDefinition: View {

        let data: TitrationEquationData
        let resultPValue: Term.PValue
        let pkValue: Term.PValue
        let numeratorConcentration: Term.Concentration
        let denominatorConcentration: Term.Concentration
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                BoxWidthTextLine(data: data, value: resultPValue)
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
                Placeholder(data: data, value: resultPValue)
                FixedText("=")
                Placeholder(data: data, value: pkValue)
                FixedText("+")
                HStack(spacing: 0) {
                    FixedText("log")
                    FixedText("(")
                        .scaleEffect(y: layout.fractionParenHeightScaleFactor)
                    VStack(spacing: layout.fractionVSpacing) {
                        Placeholder(data: data, value: numeratorConcentration)
                        Rectangle()
                            .frame(width: 80, height: layout.fractionBarHeight)
                        Placeholder(data: data, value: denominatorConcentration)
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
                resultPValue: .hydrogen,
                pkValue: .kA,
                numeratorConcentration: .secondary,
                denominatorConcentration: .substance
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
