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
    struct PLogKValueDefinition: View {

        let data: TitrationEquationData
        let pValue: Term.Placeholder<Term.PValue>
        let kValue: Term.Placeholder<Term.KValue>
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                BoxWidthTextLine(data: data, value: pValue)
                    .frame(width: layout.boxWidth)
                FixedText("=")
                HStack(spacing: 1) {
                    FixedText("-log(")
                        .accessibility(label: Text("minus log of"))
                    BoxWidthTextLine(data: data, value: kValue)
                    FixedText(")")
                        .accessibility(hidden: true)
                }
            }
            .accessibilityElement(children: .combine)
        }
    }

    struct PLogKValueFilled: View {

        let data: TitrationEquationData
        let pValue: Term.Placeholder<Term.PValue>
        let kValue: Term.Placeholder<Term.KValue>
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                PlaceholderEquation(data: data, value: pValue)
                    .frame(width: layout.boxWidth)
                FixedText("=")
                HStack(spacing: 0) {
                    FixedText("-log(")
                        .accessibility(label: Text("minus log"))

                    Placeholder(data: data, value: kValue)

                    FixedText(")")
                        .accessibility(hidden: true)
                }
            }
            .accessibilityElement(children: .contain)
        }
    }
}

struct PLogKValue_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TitrationEquationView.PLogKValueDefinition(
                data: .preview,
                pValue: .init(.kA, isFilled: true),
                kValue: .init(.kA, isFilled: true)
            )

            TitrationEquationView.PLogKValueFilled(
                data: .preview,
                pValue: .init(.kA, isFilled: false),
                kValue: .init(.kB, isFilled: false)
            )

            TitrationEquationView.PLogKValueFilled(
                data: .preview,
                pValue: .init(.kA, isFilled: true),
                kValue: .init(.kB, isFilled: true)
            )
        }
    }
}
