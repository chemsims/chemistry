//
// Reactions App
//

import SwiftUI
import ReactionsCore

// See comment in TitrationEquationMolesToMolarity.swift
private typealias BoxWidthTextLine = TitrationEquationView.BoxWidthTextLine
private typealias Placeholder = TitrationEquationView.PlaceholderTermView

extension TitrationEquationView {
    struct PLogConcentrationDefinition: View {

        let data: TitrationEquationData
        let pValue: Term.PValue
        let concentration: Term.Concentration
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                HStack(spacing: 0) {
                    BoxWidthTextLine(data: data, value: pValue)
                    FixedText("=")
                    FixedText("-")
                    HStack(spacing: 0) {
                        FixedText("log")
                        BoxWidthTextLine(data: data, value: concentration)
                    }
                }
            }
            .font(.system(size: layout.fontSize))
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
                    Placeholder(data: data, value: pValue)
                    FixedText("=")
                    FixedText("-")
                    HStack(spacing: 0) {
                        FixedText("log")
                        Placeholder(data: data, value: concentration)
                    }
                }
            }
            .font(.system(size: layout.fontSize))
        }
    }
}


struct TitrationEquationPLogConcentration: PreviewProvider {
    static var previews: some View {
        VStack {
            TitrationEquationView.PLogConcentrationDefinition(
                data: .preview,
                pValue: .hydrogen,
                concentration: .hydrogen
            )

            TitrationEquationView.PLogConcentrationFilled(
                data: .preview,
                pValue: .init(.hydrogen, isFilled: false),
                concentration: .init(.hydrogen, isFilled: false)
            )
        }
        .previewLayout(.sizeThatFits)
    }
}
