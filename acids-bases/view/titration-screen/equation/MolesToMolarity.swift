//
// Reactions App
//

import SwiftUI
import ReactionsCore

// There is a bug (as of Xcode 12.5) where the preview crashes when referring
//to the nested type directly from another nested type, even though it
// compiles and runs fine. These type aliases are defined as a workaround, to
// avoid using fully qualified names everywhere.
private typealias BoxWidthTextLine = TitrationEquationView.BoxWidthTextLine
private typealias Placeholder = TitrationEquationView.PlaceholderTermView
private typealias PlaceholderEquation = TitrationEquationView.PlaceholderEquationView

extension TitrationEquationView {
    struct MolesToMolarityDefinition: View {

        let data: TitrationEquationData
        let moles: Term.Placeholder<Term.Moles>
        let volume: Term.Placeholder<Term.Volume>
        let molarity: Term.Placeholder<Term.Molarity>

        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                BoxWidthTextLine(data: data, value: moles)

                FixedText("=")

                BoxWidthTextLine(data: data, value: volume)
                    .frame(width: layout.boxWidth)

                FixedText("x")
                    .accessibility(label: Text("times"))

                BoxWidthTextLine(data: data, value: molarity)
                    .frame(width: layout.boxWidth)
            }
            .font(.system(size: layout.fontSize))
            .accessibilityElement(children: .combine)
        }
    }
}


extension TitrationEquationView {
    struct MolesToMolarityFilled: View {
        let data: TitrationEquationData
        let moles:  Term.Placeholder<Term.Moles>
        let volume: Term.Placeholder<Term.Volume>
        let molarity: Term.Placeholder<Term.Molarity>
        @Environment(\.titrationEquationLayout) var layout

        var body: some View {
            HStack(spacing: layout.termsHSpacing) {
                PlaceholderEquation(data: data, value: moles)

                FixedText("=")

                PlaceholderEquation(data: data, value: volume)
                    .frame(width: layout.boxWidth)

                FixedText("x")
                    .accessibility(label: Text("times"))

                PlaceholderEquation(data: data, value: molarity)
                    .frame(width: layout.boxWidth)
            }
            .font(.system(size: layout.fontSize))
        }
    }
}

struct TitrationEquationMolesToMolarity_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TitrationEquationView.MolesToMolarityDefinition(
                data: .preview,
                moles: .init(.hydrogen, isFilled: true),
                volume: .init(.hydrogen, isFilled: true),
                molarity: .init(.hydrogen, isFilled: true)
            )

            TitrationEquationView.MolesToMolarityFilled(
                data: .preview,
                moles: .init(.hydrogen, isFilled: false),
                volume: .init(.hydrogen, isFilled: false),
                molarity: .init(.hydrogen, isFilled: false)
            )

            TitrationEquationView.MolesToMolarityFilled(
                data: .preview,
                moles: .init(.hydrogen, isFilled: true),
                volume: .init(.hydrogen, isFilled: true),
                molarity: .init(.hydrogen, isFilled: true)
            )
        }
        .previewLayout(.sizeThatFits)
    }
}
