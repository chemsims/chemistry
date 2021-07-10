//
// Reactions App
//

import SwiftUI
import ReactionsCore

// See comment in TitrationEquationMolesToMolarity.swift
private typealias TermOrPlaceholder = TitrationEquationView.BoxWidthTermOrPlaceholder
private typealias BoxWidthTextLine = TitrationEquationView.BoxWidthTextLine
private typealias PlaceholderEquation = TitrationEquationView.PlaceholderEquationView

extension TitrationEquationView {
    struct PHSumDefinition: View {

        let data: TitrationEquationData
        let firstPValue: Term.Placeholder<Term.PValue>
        let secondPValue: Term.Placeholder<Term.PValue>
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                FixedText("14")
                FixedText("=")
                BoxWidthTextLine(data: data, value: firstPValue)
                FixedText("+")
                BoxWidthTextLine(data: data, value: secondPValue)
            }
            .font(.system(size: layout.fontSize))
        }
    }

    struct PHSumFilled: View {

        let data: TitrationEquationData
        let firstPValue: Term.Placeholder<Term.PValue>
        let secondPValue: Term.Placeholder<Term.PValue>
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                FixedText("14")
                FixedText("=")
                PlaceholderEquation(data: data, value: firstPValue)
                FixedText("+")
                PlaceholderEquation(data: data, value: secondPValue)
            }
            .font(.system(size: layout.fontSize))
        }
    }
}

struct TitrationEquationPhSum_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TitrationEquationView.PHSumDefinition(
                data: .preview,
                firstPValue: .init(.hydrogen, isFilled: true),
                secondPValue: .init(.hydroxide, isFilled: true)
            )

            TitrationEquationView.PHSumFilled(
                data: .preview,
                firstPValue: .init(.hydrogen, isFilled: false),
                secondPValue: .init(.hydrogen, isFilled: false)
            )

            TitrationEquationView.PHSumFilled(
                data: .preview,
                firstPValue: .init(.hydrogen, isFilled: true),
                secondPValue: .init(.hydrogen, isFilled: true)
            )
        }
        .previewLayout(.sizeThatFits)
    }
}
