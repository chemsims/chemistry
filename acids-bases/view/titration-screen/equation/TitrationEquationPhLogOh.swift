//
// Reactions App
//


import SwiftUI
import ReactionsCore

// See comment in TitrationEquationMolesToMolarity.swift
private typealias BoxWidthTextLine = TitrationEquationView.BoxWidthTextLine
private typealias Placeholder = TitrationEquationView.PlaceholderTermView

extension TitrationEquationView {
    
    struct PhLogOHDefinition: View {
        let data: TitrationEquationData
        let pH: Term.PValue
        let pOH: Term.PValue
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                BoxWidthTextLine(data: data, value: pH)
                FixedText("=")
                FixedText("14")
                FixedText("+")
                BoxWidthTextLine(data: data, value: pOH)
            }
            .font(.system(size: layout.fontSize))
        }
    }

    struct PhLogOHFilled: View {
        let data: TitrationEquationData
        let pH: Term.Placeholder<Term.PValue>
        let pOH: Term.Placeholder<Term.PValue>
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                Placeholder(data: data, value: pH)
                FixedText("=")
                FixedText("14")
                FixedText("+")
                Placeholder(data: data, value: pOH)
            }
            .font(.system(size: layout.fontSize))
        }
    }
}

struct TitrationEquationPhLogOh_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TitrationEquationView.PhLogOHDefinition(
                data: .preview,
                pH: .hydrogen,
                pOH: .hydroxide
            )

            TitrationEquationView.PhLogOHFilled(
                data: .preview,
                pH: .init(.hydrogen, isFilled: false),
                pOH: .init(.hydroxide, isFilled: false)
            )

            TitrationEquationView.PhLogOHFilled(
                data: .preview,
                pH: .init(.hydrogen, isFilled: true),
                pOH: .init(.hydroxide, isFilled: true)
            )
        }
        .previewLayout(.sizeThatFits)
    }
}
