//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct IntroEquationView: View {

    let concentration: PrimaryIonValue<PrimaryIonConcentration>
    let showValues: Bool

    var body: some View {
        GeometryReader { geo in
            ScaledView(
                naturalWidth: NaturalWidth,
                naturalHeight: NaturalHeight,
                maxWidth: geo.size.width,
                maxHeight: geo.size.height
            ) {
                SizedIntroEquationView(
                    concentration: concentration,
                    showValues: showValues
                )
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

private let NaturalWidth: CGFloat = 735
private let NaturalHeight: CGFloat = 105
private let vSpacing: CGFloat = 15

private struct SizedIntroEquationView: View {

    let concentration: PrimaryIonValue<PrimaryIonConcentration>
    let showValues: Bool

    var body: some View {
        HStack(spacing: 20) {
            PLogEquationView(
                symbol: "H",
                charge: "+",
                concentration: concentration.hydrogen,
                showValues: showValues
            )

            PLogEquationView(
                symbol: "OH",
                charge: "-",
                concentration: concentration.hydroxide,
                showValues: showValues
            )


            phSum
        }
        .font(.system(size: EquationSizing.fontSize))
    }

    private var phSum: some View {
        VStack(spacing: vSpacing) {
            phSumTop
            phSumBottom
        }
    }

    private var phSumTop: some View {
        HStack(spacing: 0) {
            FixedText("pH")
                .frame(width: EquationSizing.boxWidth)
            FixedText("+")
            FixedText("pOH")
                .frame(width: EquationSizing.boxWidth)
            FixedText("=")
            FixedText("14")
        }
    }

    private var phSumBottom: some View {
        HStack(spacing: 0) {
            PlaceholderTerm(
                value: showValues ? concentration.hydrogen.p.str(decimals: 1) : nil,
                emphasise: true
            )
            FixedText("+")
            PlaceholderTerm(
                value: showValues ? concentration.hydroxide.p.str(decimals: 1) : nil,
                emphasise: true
            )
            FixedText("=")
            FixedText("14")
        }
    }
}

private struct PLogEquationView: View {

    let symbol: String
    let charge: String

    let concentration: PrimaryIonConcentration
    let showValues: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: vSpacing) {
            definition
            filled
        }
    }

    private var definition: some View {
        HStack(spacing: 0) {
            FixedText("p\(symbol)")
                .frame(width: EquationSizing.boxWidth)
            FixedText("=")
            FixedText("-log[")
            FixedText(symbol)
            FixedText(charge)
                .font(.system(size: EquationSizing.subscriptFontSize))
                .offset(y: -10)
            FixedText("]")
        }
    }

    private var filled: some View {
        HStack(spacing: 0) {
            PlaceholderTerm(
                value: showValues ? concentration.p.str(decimals: 1) : nil,
                emphasise: true
            )
            FixedText("=")
            FixedText("-log")
            ConcentrationPlaceholder(
                concentration: concentration.concentration,
                showValue: showValues
            )
        }
    }
}

struct IntroEquationView_Previews: PreviewProvider {
    static var previews: some View {
        SizedIntroEquationView(
            concentration: PrimaryIonValue.constant(
                PrimaryIonConcentration(concentration: 1e-4)
            ),
            showValues: true
        )
        .previewLayout(.sizeThatFits)
        .border(Color.red)
        .frame(width: NaturalWidth, height: NaturalHeight)
    }
}
