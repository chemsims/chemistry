//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct SolubilityQuotientRecapEquations: View {

    let reaction: SolubleReactionType

    var body: some View {
        GeometryReader { geo in
            ScaledView(
                naturalWidth: NaturalWidth,
                naturalHeight: NaturalHeight,
                maxWidth: geo.size.width,
                maxHeight: geo.size.height
            ) {
                SizedSolubilityQuotientRecapEquations(reaction: reaction)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

private struct SizedSolubilityQuotientRecapEquations: View {

    let reaction: SolubleReactionType

    var body: some View {
        HStack(spacing: 0) {
            AqueousQuotientRecap(products: reaction.products)
            Spacer()
                .frame(width: 40)
            GaseousQuotientRecap(products: reaction.products)
        }
        .font(.system(size: EquationSizing.fontSize))
    }
}

private struct AqueousQuotientRecap: View {

    let products: SolubleProductPair

    var body: some View {
        GeneralRecap(
            products: products,
            title: "Aqueous compounds",
            elementType: "aq"
        ) { element in
            FixedText("[\(element)]")
        }
    }
}

private struct GaseousQuotientRecap: View {

    let products: SolubleProductPair

    var body: some View {
        GeneralRecap(
            products: products,
            title: "Gaseous compounds",
            elementType: "g"
        ) { element in
            HStack(alignment: .bottom, spacing: 0) {
                FixedText("P")
                Text(element)
                    .font(.system(size: EquationSizing.subscriptFontSize))
            }
        }
    }
}

private struct GeneralRecap<Content: View>: View  {

    let products: SolubleProductPair
    let title: String
    let elementType: String
    let formatElement: (String) -> Content


    var body: some View {
        VStack(spacing: 5) {
            FixedText(title)
                .foregroundColor(.orangeAccent)
            decomposition
            quotient
        }
    }

    private var decomposition: some View {
        HStack(spacing: 5) {
            elementWithType(products.salt)
            FixedText("➝")
            elementWithType(products.first)
            FixedText("+")
            elementWithType(products.second)
        }
    }

    private var quotient: some View {
        HStack(spacing: 5) {
            FixedText("Q")
            FixedText("=")
            VStack(spacing: 2) {
                HStack(spacing: 2) {
                    formatElement(products.first)
                    formatElement(products.second)
                }
                Rectangle()
                    .frame(width: 90, height: 2)
                formatElement(products.salt)
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

private let NaturalWidth: CGFloat = 587
private let NaturalHeight: CGFloat = 169

struct SolubilityQuotientRecapEquations_Previews: PreviewProvider {
    static var previews: some View {
        SizedSolubilityQuotientRecapEquations(reaction: .C)
            .border(Color.red)
            .frame(width: NaturalWidth, height: NaturalHeight)
            .border(Color.black)
            .previewLayout(.iPhone12ProMaxLandscape)
    }
}
