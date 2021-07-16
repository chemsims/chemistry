//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct IntroEquationView: View {

    let concentration: PrimaryIonValue<PrimaryIonConcentration>
    let showValues: Bool
    let highlights: HighlightedElements<IntroScreenElement>

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
                    showValues: showValues,
                    highlights: highlights
                )
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

private let NaturalWidth: CGFloat = 800
private let NaturalHeight: CGFloat = 115
private let vSpacing: CGFloat = 25
private let equalsTrailingSpacing: CGFloat = 5

private struct SizedIntroEquationView: View {

    let concentration: PrimaryIonValue<PrimaryIonConcentration>
    let showValues: Bool
    let highlights: HighlightedElements<IntroScreenElement>

    var body: some View {
        HStack(spacing: 30) {
            PLogEquationView(
                symbol: "H",
                charge: "+",
                concentration: concentration.hydrogen,
                showValues: showValues
            )
            .background(equationBackground)
            .colorMultiply(highlights.colorMultiply(for: .pHEquation))

            PLogEquationView(
                symbol: "OH",
                charge: "-",
                concentration: concentration.hydroxide,
                showValues: showValues
            )
            .background(equationBackground)
            .colorMultiply(highlights.colorMultiply(for: .pOHEquation))

            phSum
        }
        .font(.system(size: EquationSizing.fontSize))
        .minimumScaleFactor(0.5)
    }

    private var equationBackground: some View {
        Color.white.padding(.horizontal, -2)
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
                .padding(.trailing, equalsTrailingSpacing)
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
                .padding(.trailing, equalsTrailingSpacing)
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
                .padding(.trailing, equalsTrailingSpacing)
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
            HStack(spacing: equalsTrailingSpacing) {
                FixedText("=")
                FixedText("-log")
                ConcentrationPlaceholder(
                    concentration: concentration.concentration,
                    showValue: showValues
                )
            }
        }
    }
}

struct IntroEquationView_Previews: PreviewProvider {
    static var previews: some View {
        SizedIntroEquationView(
            concentration: PrimaryIonValue.constant(
                PrimaryIonConcentration(concentration: 1e-4)
            ),
            showValues: true,
            highlights: .init(elements: [.pHEquation])
        )
        .previewLayout(.sizeThatFits)
        .border(Color.red)
        .frame(width: NaturalWidth, height: NaturalHeight)
        .background(Styling.inactiveScreenElement.padding(-10))
        .padding(10)
    }
}
