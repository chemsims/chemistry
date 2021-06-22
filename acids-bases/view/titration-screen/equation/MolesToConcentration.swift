//
// Reactions App
//


import SwiftUI
import ReactionsCore

// See comment in TitrationEquationMolesToMolarity.swift
private typealias BoxWidthTextLine = TitrationEquationView.BoxWidthTextLine
private typealias Placeholder = TitrationEquationView.PlaceholderTermView

extension TitrationEquationView {
    struct MolesToConcentrationDefinition: View {
        let data: TitrationEquationData
        let moles: Term.Moles
        let concentration: Term.Concentration
        let volume: Term.Volume
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                BoxWidthTextLine(data: data, value: moles)
                FixedText("=")
                BoxWidthTextLine(data: data, value: concentration)
                FixedText("x")
                BoxWidthTextLine(data: data, value: volume)
            }
            .font(.system(size: layout.fontSize))
        }
    }

    struct MolesToConcentrationFilled: View {
        let data: TitrationEquationData
        let moles: Term.Placeholder<Term.Moles>
        let concentration: Term.Placeholder<Term.Concentration>
        let volume: Term.Placeholder<Term.Volume>
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                Placeholder(data: data, value: moles)
                FixedText("=")
                Placeholder(data: data, value: concentration)
                FixedText("x")
                Placeholder(data: data, value: volume)
            }
            .font(.system(size: layout.fontSize))
        }
    }
}

struct TitrationEquationMolesToVolume_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TitrationEquationView.MolesToConcentrationDefinition(
                data: .preview,
                moles: .hydrogen,
                concentration: .hydrogen,
                volume: .hydrogen
            )

            TitrationEquationView.MolesToConcentrationFilled(
                data: .preview,
                moles: .init(.hydrogen, isFilled: false),
                concentration: .init(.hydrogen, isFilled: false),
                volume: .init(.hydrogen, isFilled: false)
            )

            TitrationEquationView.MolesToConcentrationFilled(
                data: .preview,
                moles: .init(.hydrogen, isFilled: true),
                concentration: .init(.hydrogen, isFilled: true),
                volume: .init(.hydrogen, isFilled: true)
            )
        }
        .previewLayout(.sizeThatFits)
    }
}
