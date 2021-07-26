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
    
    struct PLogComplementConcentrationDefinition: View {
        let data: TitrationEquationData
        let pH: Term.Placeholder<Term.PValue>
        let concentration: Term.Placeholder<Term.Concentration>
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                BoxWidthTextLine(data: data, value: pH)
                    .frame(width: layout.boxWidth)
                FixedText("=")
                FixedText("14")
                FixedText("+")
                HStack(spacing: 0) {
                    FixedText("log of")
                    BoxWidthTextLine(data: data, value: concentration)
                }
            }
            .font(.system(size: layout.fontSize))
            .minimumScaleFactor(layout.minScaleFactor)
            .lineLimit(1)
            .accessibilityElement(children: .combine)
        }
    }

    struct PLogComplementConcentrationDefinitionFilled: View {
        let data: TitrationEquationData
        let pValue: Term.Placeholder<Term.PValue>
        let concentration: Term.Placeholder<Term.Concentration>
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                PlaceholderEquation(data: data, value: pValue)
                    .frame(width: layout.boxWidth)
                FixedText("=")
                FixedText("14")
                FixedText("+")
                HStack(spacing: 0) {
                    FixedText("log(")
                        .accessibility(label: Text("log"))
                    PlaceholderEquation(data: data, value: concentration)
                    FixedText(")")
                        .accessibility(hidden: true)
                }
            }
            .font(.system(size: layout.fontSize))
            .accessibilityElement(children: .contain)
        }
    }
}

struct TitrationEquationPhLogOh_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TitrationEquationView.PLogComplementConcentrationDefinition(
                data: .preview,
                pH: .init(.hydrogen, isFilled: true),
                concentration: .init(.hydroxide, isFilled: true)
            )

            TitrationEquationView.PLogComplementConcentrationDefinitionFilled(
                data: .preview,
                pValue: .init(.hydrogen, isFilled: false),
                concentration: .init(.hydroxide, isFilled: false)
            )

            TitrationEquationView.PLogComplementConcentrationDefinitionFilled(
                data: .preview,
                pValue: .init(.hydrogen, isFilled: true),
                concentration: .init(.hydroxide, isFilled: true)
            )
        }
        .previewLayout(.sizeThatFits)
    }
}
