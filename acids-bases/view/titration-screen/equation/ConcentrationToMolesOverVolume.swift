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
    struct ConcentrationToMolesOverVolumeDefinition: View {

        let data: TitrationEquationData
        let concentration: Term.Concentration
        let moles: Term.Moles
        let firstVolume: Term.Volume
        let secondVolume: Term.Volume
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                BoxWidthTextLine(data: data, value: concentration)
                FixedText("=")
                BoxWidthTextLine(data: data, value: moles)
                FixedText("/")
                FixedText("(")
                BoxWidthTextLine(data: data, value: firstVolume)
                FixedText("+")
                BoxWidthTextLine(data: data, value: secondVolume)
                FixedText(")")
            }
            .font(.system(size: layout.fontSize))
        }
    }

    struct ConcentrationToMolesOverVolumeFilled: View {

        let data: TitrationEquationData
        let concentration: Term.Placeholder<Term.Concentration>
        let moles: Term.Placeholder<Term.Moles>
        let firstVolume: Term.Placeholder<Term.Volume>
        let secondVolume: Term.Placeholder<Term.Volume>
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                PlaceholderEquation(data: data, value: concentration)
                FixedText("=")
                PlaceholderEquation(data: data, value: moles)
                FixedText("/")
                FixedText("(")
                PlaceholderEquation(data: data, value: firstVolume)
                FixedText("+")
                PlaceholderEquation(data: data, value: secondVolume)
                FixedText(")")
            }
            .font(.system(size: layout.fontSize))
        }
    }
}

struct TitrationEquationConcentrationToVolume_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TitrationEquationView.ConcentrationToMolesOverVolumeDefinition(
                data: .preview,
                concentration: .hydrogen,
                moles: .hydrogen,
                firstVolume: .hydrogen,
                secondVolume: .titrant
            )

            TitrationEquationView.ConcentrationToMolesOverVolumeFilled(
                data: .preview,
                concentration: .init(.hydrogen, isFilled: false),
                moles: .init(.hydrogen, isFilled: false),
                firstVolume: .init(.hydrogen, isFilled: false),
                secondVolume: .init(.titrant, isFilled: false)
            )

            TitrationEquationView.ConcentrationToMolesOverVolumeFilled(
                data: .preview,
                concentration: .init(.hydrogen, isFilled: true),
                moles: .init(.hydrogen, isFilled: true),
                firstVolume: .init(.hydrogen, isFilled: true),
                secondVolume: .init(.titrant, isFilled: true)
            )
        }
        .previewLayout(.sizeThatFits)
    }
}
