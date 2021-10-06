//
// Reactions App
//

import ReactionsCore
import SwiftUI
import ReactionRates
import AcidsBases

struct PrecipitationEquationView: View {

    let data: PrecipitationEquationView.EquationData
    let reactionProgress: CGFloat
    let state: PrecipitationScreenViewModel.EquationState

    var body: some View {
        GeometryReader { geo in
            ScaledView(
                naturalWidth: NaturalWidth,
                naturalHeight: NaturalHeight,
                maxWidth: geo.size.width,
                maxHeight: geo.size.height
            ) {
                SizedPrecipitationEquationView(
                    data: data,
                    reactionProgress: reactionProgress,
                    state: state
                )
            }
            .frame(size: geo.size)
        }
    }
}

private let NaturalWidth: CGFloat = 300
private let NaturalHeight: CGFloat = 450

extension PrecipitationEquationView {
    struct EquationData {
        let beakerVolume: CGFloat

        let knownReactant: String
        let product: String
        let unknownReactant: String

        let highlightUnknownReactantFirstTerm: Bool

        let knownReactantMolarity: CGFloat
        let knownReactantMoles: CGFloat

        let productMolarMass: Int
        let productMoles: Equation
        let productMass: Equation

        let unknownReactantMolarMass: Int
        let unknownReactantMoles: Equation
        let unknownReactantMass: Equation
    }
}

private let relatedEquationVSpacing: CGFloat = 10
private let equationGroupVSpacing: CGFloat = 20
private let termHSpacing: CGFloat = 5
private let fractionVSpacing: CGFloat = 2
private let subFontSize = 0.75 * EquationSizing.subscriptFontSize

private struct SizedPrecipitationEquationView: View {

    let data: PrecipitationEquationView.EquationData
    let reactionProgress: CGFloat
    let state: PrecipitationScreenViewModel.EquationState

    var body: some View {
        HStack(spacing: 30) {
            VStack(alignment: .leading, spacing: equationGroupVSpacing) {
                KnownReactantMolesToVolume(data: data, showData: state >= .showKnownReactantMolarity)
                UnknownReactantMoles(
                    data: data,
                    reactionProgress: reactionProgress,
                    showData: state >= .showAll
                )
            }
            VStack(alignment: .leading, spacing: equationGroupVSpacing) {
                ProductMoles(
                    data: data,
                    reactionProgress: reactionProgress,
                    showData: state >= .showAll
                )
                UnknownReactantMolarMass(
                    data: data,
                    reactionProgress: reactionProgress,
                    showData: state >= .showAll
                )
            }
        }
        .font(.system(size: EquationSizing.fontSize))
    }
}

private struct KnownReactantMolesToVolume: View {

    let data: PrecipitationEquationView.EquationData
    let showData: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: relatedEquationVSpacing) {
            filled
            blank
        }
    }

    private var filled: some View {
        HStack(spacing: termHSpacing) {
            TermView(base: "n", subTerm: data.knownReactant)
                .frame(width: EquationSizing.boxWidth)
            FixedText("=")
            FixedText("V")
                .frame(width: EquationSizing.boxWidth)
            FixedText("x")
            TermView(base: "M", subTerm: data.knownReactant)
                .frame(minWidth: EquationSizing.boxWidth)
        }
    }

    private var blank: some View {
        HStack(spacing: termHSpacing) {
            PlaceholderTerm(
                value: showData ? data.knownReactantMoles.str(decimals: 2) : nil,
                emphasise: true
            )
            FixedText("=")
            FixedText(data.beakerVolume.str(decimals: 2))
                .foregroundColor(.orangeAccent)
                .frame(width: EquationSizing.boxWidth)
            FixedText("x")
            PlaceholderTerm(
                value: showData ? data.knownReactantMolarity.str(decimals: 2) : nil,
                emphasise: true
            )
        }
    }
}

private struct ProductMoles: View {

    let data: PrecipitationEquationView.EquationData
    let reactionProgress: CGFloat
    let showData: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: relatedEquationVSpacing) {
            filled
            blank
        }
    }

    private var filled: some View {
        HStack(spacing: termHSpacing) {
            TermView(base: "n", subTerm: data.product)
                .frame(width: EquationSizing.boxWidth)

            FixedText("=")
            VStack(spacing: fractionVSpacing) {
                TermView(base: "m", subTerm: data.product)
                Rectangle()
                    .frame(width: 100, height: 2)
                TermView(base: "MM", subTerm: data.product)
            }
        }
    }

    private var blank: some View {
        HStack(spacing: termHSpacing) {
            AnimatingNumberPlaceholder(
                showTerm: showData,
                progress: reactionProgress,
                equation: data.productMoles
            )
            .frame(size: EquationSizing.boxSize)

            FixedText("=")
            VStack(spacing: fractionVSpacing) {
                AnimatingNumberPlaceholder(
                    showTerm: showData,
                    progress: reactionProgress,
                    equation: data.productMass
                )
                .frame(size: EquationSizing.boxSize)

                Rectangle()
                    .frame(width: 100, height: 2)
                FixedText("\(data.productMolarMass)")
            }
        }
    }
}

private struct UnknownReactantMoles: View {

    let data: PrecipitationEquationView.EquationData
    let reactionProgress: CGFloat
    let showData: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: relatedEquationVSpacing) {
            filled
            blank
        }
    }

    private var filled: some View {
        HStack(spacing: termHSpacing) {
            TermView(base: "n", subTerm: data.product)
                .frame(width: EquationSizing.boxWidth)
            FixedText("=")
            TermView(
                base: "n",
                subTerm: data.unknownReactant,
                highlightFirstSubCharacter: data.highlightUnknownReactantFirstTerm,
                underlineTerm: "react"
            )
        }
    }

    private var blank: some View {
        HStack(spacing: termHSpacing) {
            animatingNumber(equation: data.productMoles)
            FixedText("=")
            animatingNumber(equation: data.unknownReactantMoles)
        }
    }

    private func animatingNumber(equation: Equation) -> some View {
        AnimatingNumberPlaceholder(
            showTerm: showData,
            progress: reactionProgress,
            equation: data.unknownReactantMoles
        )
        .frame(size: EquationSizing.boxSize)
    }
}

private struct UnknownReactantMolarMass: View {

    let data: PrecipitationEquationView.EquationData
    let reactionProgress: CGFloat
    let showData: Bool

    var body: some View {
        VStack(spacing: relatedEquationVSpacing) {
            filled
            blank
        }
    }

    private var filled: some View {
        HStack(spacing: termHSpacing) {
            TermView(
                base: "MM",
                subTerm: data.unknownReactant,
                highlightFirstSubCharacter: data.highlightUnknownReactantFirstTerm
            )
            FixedText("=")
            VStack(spacing: fractionVSpacing) {
                TermView(
                    base: "m",
                    subTerm: data.unknownReactant,
                    highlightFirstSubCharacter: data.highlightUnknownReactantFirstTerm
                )
                Rectangle()
                    .frame(width: 100, height: 2)
                TermView(
                    base: "n",
                    subTerm: data.unknownReactant,
                    highlightFirstSubCharacter: data.highlightUnknownReactantFirstTerm,
                    underlineTerm: "react"
                )
            }
        }
    }

    private var blank: some View {
        HStack(spacing: termHSpacing) {
            PlaceholderTerm(value: showData ? "\(data.unknownReactantMolarMass)" : nil)
            FixedText("=")
            VStack(spacing: relatedEquationVSpacing) {
                AnimatingNumberPlaceholder(
                    showTerm: showData,
                    progress: reactionProgress,
                    equation: data.unknownReactantMass,
                    formatter: { $0.str(decimals: 2) }
                )
                .frame(size: EquationSizing.boxSize)

                Rectangle()
                    .frame(width: 100, height: 2)

                AnimatingNumberPlaceholder(
                    showTerm: showData,
                    progress: reactionProgress,
                    equation: data.unknownReactantMoles
                )
                .frame(size: EquationSizing.boxSize)
            }
        }
    }
}

private struct TermView: View {

    init(
        base: String,
        subTerm: String,
        highlightFirstSubCharacter: Bool = false,
        underlineTerm: String? = nil
    ) {
        self.base = base
        self.subTerm = subTerm
        self.highlightFirstSubCharacter = highlightFirstSubCharacter
        self.underlineTerm = underlineTerm
    }

    let base: String
    let subTerm: String
    let highlightFirstSubCharacter: Bool
    let underlineTerm: String?

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                FixedText(base)
                    .font(.system(size: EquationSizing.fontSize))
                subTermText
                    .fixedSize()
                    .font(.system(size: subFontSize))
                    .frame(height: 38, alignment: .bottom)
            }
            if let underlineTerm = underlineTerm {
                FixedText("(\(underlineTerm))")
                    .font(.system(size: subFontSize))
            }
        }
        .lineLimit(1)
    }

    @ViewBuilder
    private var subTermText: some View {
        if let first = subTerm.first {
            Text(String(first))
                .foregroundColor(highlightFirstSubCharacter ? .orangeAccent : .black)
                + Text(subTerm.dropFirst())
        }
    }
}

struct PrecipitationEquationView_Previews: PreviewProvider {
    static var previews: some View {
        SizedPrecipitationEquationView(
            data: .init(
                beakerVolume: 0.4,
                knownReactant: "CaCl2",
                product: "CaCO3",
                unknownReactant: "M2CaC3",
                highlightUnknownReactantFirstTerm: false,
                knownReactantMolarity: 0.23,
                knownReactantMoles: 0.03,
                productMolarMass: 187,
                productMoles: ConstantEquation(value: 0.45),
                productMass: ConstantEquation(value: 1.23),
                unknownReactantMolarMass: 100,
                unknownReactantMoles: ConstantEquation(value: 0.23),
                unknownReactantMass: ConstantEquation(value: 0.4)
            ),
            reactionProgress: 0,
            state: .blank
        )
        .previewLayout(.sizeThatFits)
    }
}
