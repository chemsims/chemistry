//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct SolubilityQuotientRecapEquations: View {
    var body: some View {
        GeometryReader { geo in
            ScaledView(
                naturalWidth: NaturalWidth,
                naturalHeight: NaturalHeight,
                maxWidth: geo.size.width,
                maxHeight: geo.size.height
            ) {
                SizedSolubilityQuotientRecapEquations()
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

private struct SizedSolubilityQuotientRecapEquations: View {
    var body: some View {
        HStack(spacing: 0) {
            AqueousQuotientRecap()
            Spacer()
                .frame(width: 40)
            GaseousQuotientRecap()
        }
        .font(.system(size: EquationSizing.fontSize))
    }
}

private struct AqueousQuotientRecap: View {
    var body: some View {
        GeneralRecap(elementType: "aq") { element in
            FixedText("[\(element)]")
        }
    }
}

private struct GaseousQuotientRecap: View {
    var body: some View {
        GeneralRecap(elementType: "g") { element in
            HStack(alignment: .bottom, spacing: 0) {
                FixedText("P")
                Text(element)
                    .font(.system(size: EquationSizing.subscriptFontSize))
            }
        }
    }
}

private struct GeneralRecap<Content: View>: View  {

    let elementType: String
    let formatElement: (String) -> Content

    var body: some View {
        VStack(spacing: 5) {
            decomposition
            quotient
        }
    }

    private var decomposition: some View {
        HStack(spacing: 5) {
            elementWithType("AB")
            FixedText("➝")
            elementWithType("A")
            FixedText("+")
            elementWithType("B")
        }
    }

    private var quotient: some View {
        HStack(spacing: 5) {
            FixedText("Q")
            FixedText("=")
            VStack(spacing: 2) {
                HStack(spacing: 2) {
                    formatElement("A")
                    formatElement("B")
                }
                Rectangle()
                    .frame(width: 90, height: 2)
                formatElement("AB")
            }
        }
    }

    private func elementWithType(_ name: String) -> some View {
        HStack(spacing: 1) {
            FixedText(name)
            Text("(\(elementType))")
                .baselineOffset(-15)
                .fixedSize()
                .font(.system(size: EquationSizing.subscriptFontSize))
        }
    }
}

private let NaturalWidth: CGFloat = 535
private let NaturalHeight: CGFloat = 128

struct SolubilityQuotientRecapEquations_Previews: PreviewProvider {
    static var previews: some View {
        SizedSolubilityQuotientRecapEquations()
            .border(Color.red)
            .frame(width: NaturalWidth, height: NaturalHeight)
            .border(Color.black)
            .previewLayout(.iPhoneSELandscape)
    }
}
