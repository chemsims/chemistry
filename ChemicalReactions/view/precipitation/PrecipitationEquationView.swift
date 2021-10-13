//
// Reactions App
//

import ReactionsCore
import SwiftUI

struct PrecipitationEquationView: View {

    let data: PrecipitationEquationView.EquationData
    let reactionProgress: CGFloat
    let state: PrecipitationScreenViewModel.EquationState
    let highlights: HighlightedElements<PrecipitationScreenViewModel.ScreenElement>

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
                    state: state,
                    highlights: highlights
                )
            }
            .frame(size: geo.size)
        }
    }
}

private let NaturalWidth: CGFloat = 570
private let NaturalHeight: CGFloat = 440

extension PrecipitationEquationView {
    struct EquationData {
        let beakerVolume: CGFloat

        let knownReactant: String
        let product: String
        let unknownReactant: TextLine
        let unknownReactantCoefficient: Int

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
    let highlights: HighlightedElements<PrecipitationScreenViewModel.ScreenElement>

    var body: some View {
        HStack(spacing: 30) {
            VStack(alignment: .leading, spacing: equationGroupVSpacing) {
                KnownReactantMolesToVolume(
                    data: data,
                    showData: state >= .showKnownReactantMolarity
                )
                .colorMultiply(highlights.colorMultiply(for: nil))

                UnknownReactantMoles(
                    data: data,
                    reactionProgress: reactionProgress,
                    showData: state >= .showAll
                )
                .background(Color.white.padding(-5))
                .colorMultiply(highlights.colorMultiply(for: .unknownReactantMoles))
            }
            VStack(alignment: .leading, spacing: equationGroupVSpacing) {
                ProductMoles(
                    data: data,
                    reactionProgress: reactionProgress,
                    showData: state >= .showAll
                )
                .background(Color.white.padding(-5))
                .colorMultiply(highlights.colorMultiply(for: .productMoles))

                UnknownReactantMolarMass(
                    data: data,
                    reactionProgress: reactionProgress,
                    showData: state >= .showAll
                )
                .background(Color.white.padding(-5))
                .colorMultiply(highlights.colorMultiply(for: .unknownReactantMolarMass))
            }
        }
        .font(.system(size: EquationSizing.fontSize))
        .minimumScaleFactor(0.25)
    }
}

private struct KnownReactantMolesToVolume: View {

    let data: PrecipitationEquationView.EquationData
    let showData: Bool

    var body: some View {
        HStack(spacing: termHSpacing) {
            lhs
            VStack(alignment: .leading, spacing: relatedEquationVSpacing) {
                filled
                blank
            }
        }
    }

    private var lhs: some View {
        VStack(spacing: relatedEquationVSpacing) {
            TermView(base: "n", subTerm: data.knownReactant)
            PlaceholderTerm(
                value: showData ? data.knownReactantMoles.str(decimals: 2) : nil,
                emphasise: true
            )
        }
    }

    private var filled: some View {
        HStack(spacing: termHSpacing) {
            FixedText("=")
            FixedText("V")
                .frame(width: EquationSizing.boxWidth)
            FixedText("x")
            TermView(base: "M", subTerm: data.knownReactant)
//                .frame(width: EquationSizing.boxWidth)
        }
    }

    private var blank: some View {
        HStack(spacing: termHSpacing) {
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
            if data.unknownReactantCoefficient > 1 {
                FixedText("\(data.unknownReactantCoefficient)")
                FixedText("x")
            }
            TermView(
                base: "n",
                subTerm: data.unknownReactant,
                underlineTerm: "react"
            )
        }
    }

    private var blank: some View {
        HStack(spacing: termHSpacing) {
            animatingNumber(equation: data.productMoles)
            FixedText("=")
            if data.unknownReactantCoefficient > 1 {
                FixedText("\(data.unknownReactantCoefficient)")
                FixedText("x")
            }
            animatingNumber(equation: data.unknownReactantMoles)
        }
    }

    private func animatingNumber(equation: Equation) -> some View {
        AnimatingNumberPlaceholder(
            showTerm: showData,
            progress: reactionProgress,
            equation: equation
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
                subTerm: data.unknownReactant
            )
            FixedText("=")
            VStack(spacing: fractionVSpacing) {
                TermView(
                    base: "m",
                    subTerm: data.unknownReactant
                )
                Rectangle()
                    .frame(width: 100, height: 2)
                TermView(
                    base: "n",
                    subTerm: data.unknownReactant,
                    underlineTerm: "react"
                )
            }
        }
    }

    private var blank: some View {
        HStack(spacing: termHSpacing) {
            PlaceholderTerm(value: showData ? "\(data.unknownReactantMolarMass)" : nil)
            FixedText("=")
            VStack(spacing: fractionVSpacing) {
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
        underlineTerm: String? = nil
    ) {
        self.base = base
        self.subTerm = TextLine(subTerm)
        self.underlineTerm = underlineTerm
    }

    init(
        base: String,
        subTerm: TextLine,
        underlineTerm: String? = nil
    ) {
        self.base = base
        self.subTerm = subTerm
        self.underlineTerm = underlineTerm
    }

    let base: String
    let subTerm: TextLine
    let underlineTerm: String?

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                FixedText(base)
                    .fixedSize()
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
        .minimumScaleFactor(0.1)
    }

    private var subTermText: some View {
        subTerm.content.reduce(Text(""), {
            $0 + text($1)
        })
    }

    // We only support text emphasis for the sub text, and ignore everything else
    private func text(_ segment: TextSegment) -> Text {
        Text(segment.content)
            .foregroundColor(segment.emphasised ? .orangeAccent : .black)
    }
}

struct PrecipitationEquationView_Previews: PreviewProvider {
    static var previews: some View {
        equationView(reaction: .availableReactionsWithRandomMetals()[0])
        equationView(reaction: .availableReactionsWithRandomMetals()[1])
    }

    private static func equationView(reaction: PrecipitationReaction) -> some View {
        SizedPrecipitationEquationView(
            data: data(reaction: reaction),
            reactionProgress: 0,
            state: .showAll,
            highlights: .init(elements: [.productMoles])
        )
        .border(Color.red)
        .frame(width: NaturalWidth, height: NaturalHeight)
        .border(Color.black)
        .previewLayout(.sizeThatFits)
        .background(Styling.inactiveScreenElement)
    }

    private static func data(reaction: PrecipitationReaction) -> PrecipitationEquationView.EquationData {
        .init(
            beakerVolume: 0.4,
            knownReactant: reaction.knownReactant.name.asString,
            product: reaction.product.name.asString,
            unknownReactant: reaction.unknownReactant.name(showMetal: true, emphasiseMetal: true),
            unknownReactantCoefficient: reaction.unknownReactant.coeff,
            knownReactantMolarity: 0.23,
            knownReactantMoles: 0.03,
            productMolarMass: 187,
            productMoles: ConstantEquation(value: 0.45),
            productMass: ConstantEquation(value: 1.23),
            unknownReactantMolarMass: 100,
            unknownReactantMoles: ConstantEquation(value: 0.23),
            unknownReactantMass: ConstantEquation(value: 0.4)
        )
    }
}
