//
// Reactions App
//

import SwiftUI
import ReactionsCore

// See comment in TitrationEquationMolesToMolarity.swift
private typealias BoxWidthTextLine = TitrationEquationView.BoxWidthTextLine
private typealias Placeholder = TitrationEquationView.PlaceholderTermView

extension TitrationEquationView {
    struct ConcentrationToMolesOverVolumeDefinition: View {

        let data: TitrationEquationData
        let concentration: Term.Concentration
        let subtractingMoles: Term.Moles
        let fromMoles: Term.Moles
        let firstVolume: Term.Volume
        let secondVolume: Term.Volume
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                BoxWidthTextLine(data: data, value: concentration)
                FixedText("=")
                VStack(spacing: layout.fractionVSpacing) {
                    HStack(spacing: layout.termsHSpacing) {
                        BoxWidthTextLine(data: data, value: fromMoles)
                        FixedText("-")
                        BoxWidthTextLine(data: data, value: subtractingMoles)
                    }
                    Rectangle()
                        .frame(width: 180, height: layout.fractionBarHeight)
                    HStack(spacing: layout.termsHSpacing) {
                        BoxWidthTextLine(data: data, value: firstVolume)
                        FixedText("+")
                        BoxWidthTextLine(data: data, value: secondVolume)
                    }
                }
            }
            .font(.system(size: layout.fontSize))
        }
    }

    struct ConcentrationToMolesOverVolumeFilled: View {

        let data: TitrationEquationData
        let concentration: Term.Placeholder<Term.Concentration>
        let subtractingMoles: Term.Placeholder<Term.Moles>
        let fromMoles: Term.Placeholder<Term.Moles>
        let firstVolume: Term.Placeholder<Term.Volume>
        let secondVolume: Term.Placeholder<Term.Volume>
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                Placeholder(data: data, value: concentration)
                FixedText("=")
                VStack(spacing: layout.fractionVSpacing) {
                    HStack(spacing: layout.termsHSpacing) {
                        Placeholder(data: data, value: fromMoles)
                        FixedText("-")
                        Placeholder(data: data, value: subtractingMoles)
                    }
                    Rectangle()
                        .frame(width: 180, height: layout.fractionBarHeight)
                    HStack(spacing: layout.termsHSpacing) {
                        Placeholder(data: data, value: firstVolume)
                        FixedText("+")
                        Placeholder(data: data, value: secondVolume)
                    }
                }
            }
            .font(.system(size: layout.fontSize))
        }
    }
}

struct TitrationEquationConcentrationToMolesOverVolume_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TitrationEquationView.ConcentrationToMolesOverVolumeDefinition(
                data: .preview,
                concentration: .hydrogen,
                subtractingMoles: .hydrogen,
                fromMoles: .initialSecondary,
                firstVolume: .substance,
                secondVolume: .equivalencePoint
            )

            TitrationEquationView.ConcentrationToMolesOverVolumeFilled(
                data: .preview,
                concentration: .init(.hydrogen, isFilled: false),
                subtractingMoles: .init(.hydrogen, isFilled: false),
                fromMoles: .init(.initialSecondary, isFilled: false),
                firstVolume: .init(.substance, isFilled: false),
                secondVolume: .init(.equivalencePoint, isFilled: false)
            )

            TitrationEquationView.ConcentrationToMolesOverVolumeFilled(
                data: .preview,
                concentration: .init(.hydrogen, isFilled: true),
                subtractingMoles: .init(.hydrogen, isFilled: true),
                fromMoles: .init(.initialSecondary, isFilled: true),
                firstVolume: .init(.substance, isFilled: true),
                secondVolume: .init(.equivalencePoint, isFilled: true)
            )
        }
        .previewLayout(.sizeThatFits)
    }
}
