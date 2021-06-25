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
        let molesDifference: Term.Moles
        let subtractingMoles: Term.Moles
        let fromMoles: Term.Moles
        @Environment(\.titrationEquationLayout) var layout
        
        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                BoxWidthTextLine(data: data, value: molesDifference)
                FixedText("=")
                BoxWidthTextLine(data: data, value: fromMoles)
                FixedText("-")
                BoxWidthTextLine(data: data, value: subtractingMoles)
            }
            .font(.system(size: layout.fontSize))
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
                PlaceholderEquation(data: data, value: subtractingMoles)
            }
            .font(.system(size: layout.fontSize))
        }
    }
}

struct TitrationEquationMoleSum_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TitrationEquationView.MolesDifferenceDefinition(
                data: .preview,
                molesDifference: .substance,
                subtractingMoles: .titrant,
                fromMoles: .initialSubstance
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
