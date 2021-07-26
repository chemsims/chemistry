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
    struct PLogConcentrationDefinition: View {

        let data: TitrationEquationData
        let pValue: Term.Placeholder<Term.PValue>
        let concentration: Term.Placeholder<Term.Concentration>
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                HStack(spacing: 0) {
                    BoxWidthTextLine(data: data, value: pValue)
                        .frame(width: layout.boxWidth)
                    FixedText("=")

                    FixedText("-")
                        .accessibility(hidden: true)
                    HStack(spacing: 0) {
                        FixedText("log")
                            .accessibility(label: Text("minus log of"))
                        BoxWidthTextLine(data: data, value: concentration)
                    }
                }
            }
            .font(.system(size: layout.fontSize))
            .accessibilityElement(children: .combine)
        }
    }

    struct PLogConcentrationFilled: View {

        let data: TitrationEquationData
        let pValue: Term.Placeholder<Term.PValue>
        let concentration: Term.Placeholder<Term.Concentration>
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                HStack(spacing: 0) {
                    PlaceholderEquation(data: data, value: pValue)
                        .frame(width: layout.boxWidth)
                    FixedText("=")
                    FixedText("-")
                        .accessibility(hidden: true)
                    HStack(spacing: 0) {
                        FixedText("log")
                            .accessibility(label: Text("minus log"))
                        PlaceholderEquation(
                            data: data,
                            value: concentration
                        )
                    }
                }
            }
            .font(.system(size: layout.fontSize))
            .lineLimit(1)
            .minimumScaleFactor(layout.minScaleFactor)
            .accessibilityElement(children: .contain)
        }
    }
}


struct TitrationEquationPLogConcentration: PreviewProvider {
    static var previews: some View {
        VStack {
            TitrationEquationView.PLogConcentrationDefinition(
                data: .preview,
                pValue: .init(.hydrogen, isFilled: true),
                concentration: .init(.hydrogen, isFilled: true)
            )

            TitrationEquationView.PLogConcentrationFilled(
                data: .preview,
                pValue: .init(.hydrogen, isFilled: false),
                concentration: .init(.hydrogen, isFilled: false)
            )

            TitrationEquationView.PLogConcentrationFilled(
                data: .preview,
                pValue: .init(.hydrogen, isFilled: true),
                concentration: .init(.hydrogen, isFilled: true)
            )
        }
        .previewLayout(.sizeThatFits)
    }
}
