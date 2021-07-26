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
    struct ConcentrationToMolesDifferenceOverVolumeDefinition: View {

        let data: TitrationEquationData
        let concentration: Term.Placeholder<Term.Concentration>
        let subtractingMoles: Term.Placeholder<Term.Moles>
        let fromMoles: Term.Placeholder<Term.Moles>
        let firstVolume: Term.Placeholder<Term.Volume>
        let secondVolume: Term.Placeholder<Term.Volume>
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                BoxWidthTextLine(data: data, value: concentration)
                    .accessibility(sortPriority: 10)

                FixedText("=")
                    .accessibility(sortPriority: 9)

                VStack(spacing: layout.fractionVSpacing) {
                    HStack(spacing: layout.termsHSpacing) {
                        BoxWidthTextLine(data: data, value: fromMoles)
                            .accessibility(sortPriority: 8)

                        FixedText("-")
                            .accessibility(sortPriority: 7)
                            .accessibility(label: Text("minus"))

                        BoxWidthTextLine(data: data, value: subtractingMoles)
                            .accessibility(sortPriority: 6)
                    }

                    Rectangle()
                        .frame(width: 180, height: layout.fractionBarHeight)
                        .accessibility(sortPriority: 5)
                        .accessibility(label: Text("divide by"))

                    HStack(spacing: layout.termsHSpacing) {
                        BoxWidthTextLine(data: data, value: firstVolume)
                            .accessibility(sortPriority: 4)

                        FixedText("+")
                            .accessibility(sortPriority: 3)

                        BoxWidthTextLine(data: data, value: secondVolume)
                            .accessibility(sortPriority: 2)

                    }
                }
            }
            .font(.system(size: layout.fontSize))
            .accessibilityElement(children: .combine)
            .accessibility(sortPriority: 0)
        }
    }

    struct ConcentrationToMolesDifferenceOverVolumeFilled: View {

        let data: TitrationEquationData
        let concentration: Term.Placeholder<Term.Concentration>
        let subtractingMoles: Term.Placeholder<Term.Moles>
        let fromMoles: Term.Placeholder<Term.Moles>
        let firstVolume: Term.Placeholder<Term.Volume>
        let secondVolume: Term.Placeholder<Term.Volume>
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                PlaceholderEquation(data: data, value: concentration)
                    .accessibility(sortPriority: 10)

                FixedText("=")
                    .accessibility(sortPriority: 9)

                VStack(spacing: layout.fractionVSpacing) {
                    HStack(spacing: layout.termsHSpacing) {
                        PlaceholderEquation(data: data, value: fromMoles)
                            .accessibility(sortPriority: 8)

                        FixedText("-")
                            .accessibility(sortPriority: 7)
                            .accessibility(label: Text("minus"))

                        PlaceholderEquation(data: data, value: subtractingMoles)
                            .accessibility(sortPriority: 6)
                    }

                    Rectangle()
                        .frame(width: 180, height: layout.fractionBarHeight)
                        .accessibility(sortPriority: 5)
                        .accessibility(label: Text("divide by"))

                    HStack(spacing: layout.termsHSpacing) {
                        PlaceholderEquation(data: data, value: firstVolume)
                            .accessibility(sortPriority: 4)

                        FixedText("+")
                            .accessibility(sortPriority: 3)

                        PlaceholderEquation(data: data, value: secondVolume)
                            .accessibility(sortPriority: 2)
                    }
                }
            }
            .font(.system(size: layout.fontSize))
            .accessibilityElement(children: .contain)
        }
    }
}

struct ConcentrationToMolesDifferenceOverVolume_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TitrationEquationView.ConcentrationToMolesDifferenceOverVolumeDefinition(
                data: .preview,
                concentration: .init(.hydrogen, isFilled: true),
                subtractingMoles: .init(.hydrogen, isFilled: true),
                fromMoles: .init(.initialSecondary, isFilled: true),
                firstVolume: .init(.substance, isFilled: true),
                secondVolume: .init(.equivalencePoint, isFilled: true)
            )

            TitrationEquationView.ConcentrationToMolesDifferenceOverVolumeFilled(
                data: .preview,
                concentration: .init(.hydrogen, isFilled: false),
                subtractingMoles: .init(.hydrogen, isFilled: false),
                fromMoles: .init(.initialSecondary, isFilled: false),
                firstVolume: .init(.substance, isFilled: false),
                secondVolume: .init(.equivalencePoint, isFilled: false)
            )

            TitrationEquationView.ConcentrationToMolesDifferenceOverVolumeFilled(
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
