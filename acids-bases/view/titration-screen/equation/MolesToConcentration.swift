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
    struct MolesToConcentrationDefinition: View {
        let data: TitrationEquationData
        let moles: Term.Placeholder<Term.Moles>
        let concentration: Term.Placeholder<Term.Concentration>
        let volume: Term.Placeholder<Term.Volume>
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                BoxWidthTextLine(data: data, value: moles)
                FixedText("=")
                BoxWidthTextLine(data: data, value: concentration)
                    .frame(width: layout.boxWidth)
                FixedText("x")
                    .accessibility(label: Text("times"))
                BoxWidthTextLine(data: data, value: volume)
                    .frame(width: layout.boxWidth)
            }
            .font(.system(size: layout.fontSize))
            .accessibilityElement(children: .combine)
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
                PlaceholderEquation(data: data, value: moles)
                FixedText("=")
                PlaceholderEquation(data: data, value: concentration)
                    .frame(width: layout.boxWidth)
                FixedText("x")
                    .accessibility(label: Text("times"))
                PlaceholderEquation(data: data, value: volume)
                    .frame(width: layout.boxWidth)
            }
            .font(.system(size: layout.fontSize))
            .accessibilityElement(children: .contain)
        }
    }
}

struct TitrationEquationMolesToVolume_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TitrationEquationView.MolesToConcentrationDefinition(
                data: .preview,
                moles: .init(.hydrogen, isFilled: true),
                concentration: .init(.hydrogen, isFilled: true),
                volume: .init(.hydrogen, isFilled: true)
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
