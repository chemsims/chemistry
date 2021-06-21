//
// Reactions App
//

import SwiftUI
import ReactionsCore

// See comment in TitrationEquationMolesToMolarity.swift
private typealias BoxWidthTextLine = TitrationEquationView.BoxWidthTextLine
private typealias Placeholder = TitrationEquationView.PlaceholderTermView

extension TitrationEquationView {
    struct MoleSumDefinition: View {

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

    struct MoleSumFilled: View {

        let data: TitrationEquationData
        let molesDifference: Term.Placeholder<Term.Moles>
        let subtractingMoles: Term.Placeholder<Term.Moles>
        let fromMoles: Term.Placeholder<Term.Moles>
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                Placeholder(data: data, value: molesDifference)
                FixedText("=")
                Placeholder(data: data, value: fromMoles)
                FixedText("-")
                Placeholder(data: data, value: subtractingMoles)
            }
            .font(.system(size: layout.fontSize))
        }
    }
}

struct TitrationEquationMoleSum_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TitrationEquationView.MoleSumDefinition(
                data: .preview,
                molesDifference: .substance,
                subtractingMoles: .titrant,
                fromMoles: .initialSubstance
            )

            TitrationEquationView.MoleSumFilled(
                data: .preview,
                molesDifference: .init(.substance, isFilled: false),
                subtractingMoles: .init(.titrant, isFilled: false),
                fromMoles: .init(.initialSubstance, isFilled: false)
            )
            TitrationEquationView.MoleSumFilled(
                data: .preview,
                molesDifference: .init(.substance, isFilled: true),
                subtractingMoles: .init(.titrant, isFilled: true),
                fromMoles: .init(.initialSubstance, isFilled: true)
            )
        }
        .previewLayout(.sizeThatFits)
    }
}
