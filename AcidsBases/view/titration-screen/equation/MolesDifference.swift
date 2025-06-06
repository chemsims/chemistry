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
    struct MolesDifferenceDefinition: View {

        let data: TitrationEquationData
        let molesDifference: Term.Placeholder<Term.Moles>
        let subtractingMoles: Term.Placeholder<Term.Moles>
        let fromMoles: Term.Placeholder<Term.Moles>
        @Environment(\.titrationEquationLayout) var layout
        
        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                BoxWidthTextLine(data: data, value: molesDifference)
                FixedText("=")
                BoxWidthTextLine(data: data, value: fromMoles)
                FixedText("-")
                    .accessibility(label: Text("minus"))
                BoxWidthTextLine(data: data, value: subtractingMoles)
            }
            .font(.system(size: layout.fontSize))
            .accessibilityElement(children: .combine)
        }
    }

    struct MolesDifferenceFilled: View {

        let data: TitrationEquationData
        let molesDifference: Term.Placeholder<Term.Moles>
        let subtractingMoles: Term.Placeholder<Term.Moles>
        let fromMoles: Term.Placeholder<Term.Moles>
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                PlaceholderEquation(data: data, value: molesDifference)
                FixedText("=")
                PlaceholderEquation(data: data, value: fromMoles)
                FixedText("-")
                    .accessibility(label: Text("minus"))
                PlaceholderEquation(data: data, value: subtractingMoles)
            }
            .font(.system(size: layout.fontSize))
            .accessibilityElement(children: .contain)
        }
    }
}

struct TitrationEquationMoleSum_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TitrationEquationView.MolesDifferenceDefinition(
                data: .preview,
                molesDifference: .init(.substance, isFilled: true),
                subtractingMoles: .init(.titrant, isFilled: true),
                fromMoles: .init(.initialSubstance, isFilled: true)
            )

            TitrationEquationView.MolesDifferenceFilled(
                data: .preview,
                molesDifference: .init(.substance, isFilled: false),
                subtractingMoles: .init(.titrant, isFilled: false),
                fromMoles: .init(.initialSubstance, isFilled: false)
            )
            TitrationEquationView.MolesDifferenceFilled(
                data: .preview,
                molesDifference: .init(.substance, isFilled: true),
                subtractingMoles: .init(.titrant, isFilled: true),
                fromMoles: .init(.initialSubstance, isFilled: true)
            )
        }
        .previewLayout(.sizeThatFits)
    }
}
