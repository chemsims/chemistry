//
// Reactions App
//


import SwiftUI
import ReactionsCore

// See comment in TitrationEquationMolesToMolarity.swift
private typealias BoxWidthTextLine = TitrationEquationView.BoxWidthTextLine
private typealias PlainLine = TitrationEquationView.PlainLine
private typealias Placeholder = TitrationEquationView.PlaceholderTermView

extension TitrationEquationView {
    struct KaKbRelationDefinition: View {

        let data: TitrationEquationData
        let firstKValue: Term.Placeholder<Term.KValue>
        let secondKValue: Term.Placeholder<Term.KValue>
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                FixedText("Kw")
                    .frame(width: layout.boxWidth)
                FixedText("=")
                BoxWidthTextLine(data: data, value: firstKValue)
                FixedText("x")
                BoxWidthTextLine(data: data, value: secondKValue)
            }
            .font(.system(size: layout.fontSize))
        }
    }

    struct KaKbRelationFilled: View {

        let data: TitrationEquationData
        let firstKValue: Term.Placeholder<Term.KValue>
        let secondKValue: Term.Placeholder<Term.KValue>
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                FixedText("Kw")
                    .frame(width: layout.boxWidth)
                FixedText("=")
                Placeholder(data: data, value: firstKValue)
                FixedText("x")
                Placeholder(data: data, value: secondKValue)
            }
            .font(.system(size: layout.fontSize))
        }
    }
}

struct TitrationEquationKaKbRelation_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TitrationEquationView.KaKbRelationDefinition(
                data: .preview,
                firstKValue: .init(.kA, isFilled: true),
                secondKValue: .init(.kB, isFilled: true)
            )

            TitrationEquationView.KaKbRelationFilled(
                data: .preview,
                firstKValue: .init(.kA, isFilled: false),
                secondKValue: .init(.kB, isFilled: false)
            )

            TitrationEquationView.KaKbRelationFilled(
                data: .preview,
                firstKValue: .init(.kA, isFilled: true),
                secondKValue: .init(.kB, isFilled: true)
            )
        }
        .previewLayout(.sizeThatFits)
    }
}
