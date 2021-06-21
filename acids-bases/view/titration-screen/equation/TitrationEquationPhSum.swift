//
// Reactions App
//

import SwiftUI
import ReactionsCore

// See comment in TitrationEquationMolesToMolarity.swift
private typealias TermOrPlaceholder = TitrationEquationView.BoxWidthTermOrPlaceholder

extension TitrationEquationView {
    struct PHSumDefinition: View {

        let data: TitrationEquationData
        let firstPValue: Term.PValue
        let secondPValue: Term.PValue
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            TitrationEquationView.PHSumGeneral(
                data: data,
                showDefinition: false,
                firstPValue: .init(firstPValue, isFilled: true),
                secondPValue: .init(secondPValue, isFilled: true)
            )
        }
    }

    struct PHSumFilled: View {

        let data: TitrationEquationData
        let firstPValue: Term.Placeholder<Term.PValue>
        let secondPValue: Term.Placeholder<Term.PValue>
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            TitrationEquationView.PHSumGeneral(
                data: data,
                showDefinition: false,
                firstPValue: firstPValue,
                secondPValue: secondPValue
            )
        }
    }

    private struct PHSumGeneral: View {

        let data: TitrationEquationData
        let showDefinition: Bool
        let firstPValue: Term.Placeholder<Term.PValue>
        let secondPValue: Term.Placeholder<Term.PValue>
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                FixedText("14")
                FixedText("=")
                TermOrPlaceholder(data: data, value: firstPValue, showDefinition: showDefinition)
                FixedText("+")
                TermOrPlaceholder(data: data, value: secondPValue, showDefinition: showDefinition)
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
                firstPValue: .hydrogen,
                secondPValue: .hydroxide
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
