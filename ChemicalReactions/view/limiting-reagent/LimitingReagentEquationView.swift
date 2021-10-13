//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct LimitingReagentEquationView: View {

    let data: LimitingReagentEquationData
    let reactionProgress: CGFloat
    let showTheoreticalData: Bool
    let showActualData: Bool
    let highlights: HighlightedElements<LimitingReagentScreenViewModel.ScreenElement>

    var body: some View {
        GeometryReader { geo in
            ScaledView(
                naturalWidth: NaturalWidth,
                naturalHeight: NaturalHeight,
                maxWidth: geo.size.width,
                maxHeight: geo.size.height
            ) {
                SizedLimitingReagentEquationView(
                    data: data,
                    reactionProgress: reactionProgress,
                    showTheoreticalData: showTheoreticalData,
                    showActualData: showActualData,
                    highlights: highlights
                )
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

private let NaturalWidth: CGFloat = 1000
private let NaturalHeight: CGFloat = 400

// spacing between the 'columns' - i.e., h spacing between equation set
private let columnHSpacing: CGFloat = 60

// Height for equations without a fraction
private let singleRowEquationHeight: CGFloat = 70

// Height for an equation with a fraction
private let doubleRowEquationHeight: CGFloat = 120

// V spacing between 2 related equations
private let relatedEquationVSpacing: CGFloat = 5

// spacing between terms in an equation
private let termHSpacing: CGFloat = 5

// v spacing for fraction terms
private let fractionVSpacing: CGFloat = 2


private let subFontSize = 0.75 * EquationSizing.subscriptFontSize

private struct SizedLimitingReagentEquationView: View {

    let data: LimitingReagentEquationData
    let reactionProgress: CGFloat
    let showTheoreticalData: Bool
    let showActualData: Bool
    let highlights: HighlightedElements<LimitingReagentScreenViewModel.ScreenElement>

    var body: some View {
        VStack(spacing: 20) {
            topRow
            bottomRow
        }
        .font(.system(size: EquationSizing.fontSize))
    }

    private var topRow: some View {
        HStack(alignment: .top, spacing: columnHSpacing) {
            LimitingReactantMoles(data: data, showData: showTheoreticalData)
                .background(Color.white.padding(-2))
                .colorMultiply(highlights.colorMultiply(for: .limitingReactantMolesToVolume))

            ExcessReactantNeededMoles(data: data, showData: showTheoreticalData)
                .background(Color.white.padding(-2))
                .colorMultiply(highlights.colorMultiply(for: .neededExcessReactantMoles))

            TheoreticalProductMass(data: data, showData: showTheoreticalData)
                .background(Color.white.padding(-2))
                .colorMultiply(highlights.colorMultiply(for: .theoreticalProductMass))
        }
    }

    private var bottomRow: some View {
        HStack(alignment: .top, spacing: columnHSpacing) {
            ReactingExcessReactingMoles(
                data: data,
                showData: showActualData,
                reactionProgress: reactionProgress
            )
            .colorMultiply(highlights.colorMultiply(for: .limitingReactantMolesToVolume))

            ActualProductMoles(
                data: data,
                showData: showActualData,
                reactionProgress: reactionProgress
            )
            .colorMultiply(highlights.colorMultiply(for: .limitingReactantMolesToVolume))

            ProductYield(
                data: data,
                showTheoreticalData: showTheoreticalData,
                showActualData: showActualData,
                reactionProgress: reactionProgress
            )
            .background(Color.white.padding(-2))
            .colorMultiply(highlights.colorMultiply(for: .productYieldPercentage))
        }
    }
}

private struct LimitingReactantMoles: View {

    let data: LimitingReagentEquationData
    let showData: Bool

    var body: some View {
        HStack(spacing: termHSpacing) {
            lhs
            VStack(alignment: .leading, spacing: relatedEquationVSpacing) {
                filled
                    .frame(height: singleRowEquationHeight)
                blank
                    .frame(height: singleRowEquationHeight)
            }
        }
    }

    private var lhs: some View {
        VStack(alignment: .trailing, spacing: relatedEquationVSpacing) {
            TermView(
                base: "n",
                subTerm: data.reaction.limitingReactant.name,
                underlineTerm: nil
            )
            .frame(height: singleRowEquationHeight)

            PlaceholderTerm(
                value: showData ? data.limitingReactantMoles.str(decimals: 2) : nil,
                emphasise: true
            )
            .frame(height: singleRowEquationHeight)
        }
    }

    private var filled: some View {
        HStack(alignment: .top, spacing: termHSpacing) {
            FixedText("=")
            FixedText("V")
            FixedText("x")
            TermView(
                base: "M",
                subTerm: data.reaction.limitingReactant.name,
                underlineTerm: nil
            )
        }
    }

    private var blank: some View {
        HStack(spacing: termHSpacing) {
            FixedText("=")
            FixedText(data.volume.str(decimals: 2))
                .foregroundColor(.orangeAccent)
                .frame(width: EquationSizing.boxWidth, height: EquationSizing.boxHeight)
            FixedText("x")
            PlaceholderTerm(
                value: showData ? data.limitingReactantMolarity.str(decimals: 2) : nil,
                emphasise: true
            )
        }
    }
}

private struct ExcessReactantNeededMoles: View {
    let data: LimitingReagentEquationData
    let showData: Bool

    var body: some View {
        HStack(spacing: termHSpacing) {
            lhs
            VStack(alignment: .leading, spacing: relatedEquationVSpacing) {
                filled
                    .frame(height: singleRowEquationHeight)
                blank
                    .frame(height: singleRowEquationHeight)
            }
        }
    }

    private var lhs: some View {
        VStack(alignment: .trailing, spacing: relatedEquationVSpacing) {
            TermView(
                base: "n",
                subTerm: data.reaction.excessReactant.name,
                underlineTerm: "needed"
            )
            .frame(height: singleRowEquationHeight)

            PlaceholderTerm(
                value: showData ? data.neededExcessReactantMoles.str(decimals: 2) : nil,
                emphasise: true
            )
            .frame(height: singleRowEquationHeight)
        }
    }

    private var filled: some View {
        HStack(alignment: .top, spacing: termHSpacing) {

            FixedText("=")
            FixedText("\(data.reaction.excessReactant.coefficient)")
            FixedText("x")
            TermView(
                base: "n",
                subTerm: data.reaction.limitingReactant.name,
                underlineTerm: nil
            )
        }
    }

    private var blank: some View {
        HStack(spacing: termHSpacing) {

            FixedText("=")
            FixedText("\(data.reaction.excessReactant.coefficient)")
            FixedText("x")
            PlaceholderTerm(
                value: showData ? data.limitingReactantMoles.str(decimals: 2) : nil,
                emphasise: true
            )
        }
    }
}
private struct TheoreticalProductMass: View {
    let data: LimitingReagentEquationData
    let showData: Bool

    var body: some View {
        HStack(spacing: termHSpacing) {
            lhs
            VStack(alignment: .leading, spacing: relatedEquationVSpacing) {
                filled
                    .frame(height: singleRowEquationHeight)
                blank
                    .frame(height: singleRowEquationHeight)
            }
        }
    }

    private var lhs: some View {
        VStack(alignment: .trailing, spacing: relatedEquationVSpacing) {
            TermView(
                base: "m",
                subTerm: data.reaction.product.name,
                underlineTerm: "theoretical"
            )
            .frame(height: singleRowEquationHeight)

            PlaceholderTerm(
                value: showData ? data.theoreticalProductMass.str(decimals: 2) : nil,
                emphasise: true
            )
            .frame(height: singleRowEquationHeight)
        }
    }

    private var filled: some View {
        HStack(alignment: .top, spacing: termHSpacing) {
            FixedText("=")
            TermView(
                base: "n",
                subTerm: data.reaction.product.name,
                underlineTerm: "theoretical"
            )
            FixedText("x")
            TermView(
                base: "MM",
                subTerm: data.reaction.product.name,
                underlineTerm: nil
            )
        }
    }

    private var blank: some View {
        HStack(spacing: termHSpacing) {
            FixedText("=")
            PlaceholderTerm(
                value: showData ? data.theoreticalProductMoles.str(decimals: 2) : nil,
                emphasise: true
            )
            FixedText("x")
            FixedText("\(data.reaction.product.molarMass)")
        }
    }
}

private struct ReactingExcessReactingMoles: View {

    let data: LimitingReagentEquationData
    let showData: Bool
    let reactionProgress: CGFloat

    var body: some View {
        HStack(spacing: relatedEquationVSpacing) {
            lhs
            VStack(alignment: .leading, spacing: relatedEquationVSpacing) {
                filled
                    .frame(height: doubleRowEquationHeight)
                blank
                    .frame(height: doubleRowEquationHeight)
            }
        }
    }

    private var lhs: some View {
        VStack(alignment: .trailing, spacing: relatedEquationVSpacing) {
            TermView(
                base: "n",
                subTerm: data.reaction.excessReactant.name,
                underlineTerm: "reacts"
            )
            .frame(height: doubleRowEquationHeight)

            animatingNumber(data.reactingExcessReactantMoles, decimals: 2)
                .frame(height: doubleRowEquationHeight)
        }
    }

    private var filled: some View {
        HStack(spacing: termHSpacing) {
            FixedText("=")
            VStack(spacing: fractionVSpacing) {
                TermView(
                    base: "n",
                    subTerm: data.reaction.excessReactant.name,
                    underlineTerm: nil
                )
                Rectangle()
                    .frame(width: 110, height: 2)
                TermView(
                    base: "MM",
                    subTerm: data.reaction.excessReactant.name,
                    underlineTerm: nil
                )
            }
        }
    }

    private var blank: some View {
        HStack(spacing: termHSpacing) {
            FixedText("=")
            VStack(spacing: fractionVSpacing) {
                animatingNumber(data.reactingExcessReactantMass, decimals: 2)
                Rectangle()
                    .frame(width: 50, height: 2)
                FixedText("\(data.reaction.excessReactant.molarMass)")
                    .frame(height: EquationSizing.boxHeight)
            }
        }
    }

    private func animatingNumber(_ equation: Equation, decimals: Int) -> some View {
        AnimatingNumberPlaceholder(
            showTerm: showData,
            progress: reactionProgress,
            equation: equation,
            formatter: { $0.str(decimals: decimals) }
        )
        .frame(width: EquationSizing.boxWidth, height: EquationSizing.boxHeight)
    }
}

private struct ActualProductMoles: View {

    let data: LimitingReagentEquationData
    let showData: Bool
    let reactionProgress: CGFloat

    // We use double row height since this equation will be in the same row
    // as equations which are fractions
    var body: some View {
        HStack(spacing: termHSpacing) {
            lhs
            VStack(alignment: .leading, spacing: relatedEquationVSpacing) {
                filled
                    .frame(height: doubleRowEquationHeight)
                blank
                    .frame(height: doubleRowEquationHeight)
            }
        }
    }

    private var lhs: some View {
        VStack(alignment: .trailing, spacing: relatedEquationVSpacing) {
            TermView(
                base: "m",
                subTerm: data.reaction.product.name,
                underlineTerm: "actual"
            )
            .frame(height: doubleRowEquationHeight)

            animatingNumber(data.actualProductMass, decimals: 2)
                .frame(height: doubleRowEquationHeight)
        }
    }

    private var filled: some View {
        HStack(spacing: termHSpacing) {
            FixedText("=")
            TermView(
                base: "n",
                subTerm: data.reaction.product.name,
                underlineTerm: "actual"
            )
            FixedText("x")
            TermView(
                base: "MM",
                subTerm: data.reaction.product.name,
                underlineTerm: nil
            )
        }
    }

    private var blank: some View {
        HStack(spacing: termHSpacing) {
            FixedText("=")
            animatingNumber(data.actualProductMoles, decimals: 2)
            FixedText("x")
            FixedText("\(data.reaction.product.molarMass)")
        }
    }

    private func animatingNumber(_ equation: Equation, decimals: Int) -> some View {
        AnimatingNumberPlaceholder(
            showTerm: showData,
            progress: reactionProgress,
            equation: equation,
            formatter: { $0.str(decimals: decimals) }
        )
        .frame(width: EquationSizing.boxWidth, height: EquationSizing.boxHeight)
    }
}

private struct ProductYield: View {

    let data: LimitingReagentEquationData
    let showTheoreticalData: Bool
    let showActualData: Bool
    let reactionProgress: CGFloat

    var body: some View {
        HStack(spacing: termHSpacing) {
            lhs
            VStack(alignment: .leading, spacing: relatedEquationVSpacing) {
                filled
                    .frame(height: doubleRowEquationHeight)
                blank
                    .frame(height: doubleRowEquationHeight)
            }
        }
    }

    private var lhs: some View {
        VStack(alignment: .trailing, spacing: relatedEquationVSpacing) {
            FixedText("y(%)")
                .frame(height: doubleRowEquationHeight)

            animatingNumber(data.yield, show: showActualData, formatter: { yield in
                let perc = (yield * 100).str(decimals: 0)
                return "\(perc)%"
            })
            .frame(height: doubleRowEquationHeight)
        }
    }

    private var filled: some View {
        HStack(spacing: termHSpacing) {
            FixedText("=")
            VStack(spacing: fractionVSpacing) {
                TermView(
                    base: "m",
                    subTerm: data.reaction.product.name,
                    underlineTerm: "actual"
                )
                Rectangle()
                    .frame(width: 100, height: 2)
                TermView(
                    base: "m",
                    subTerm: data.reaction.product.name,
                    underlineTerm: "theoretical"
                )
            }
            FixedText("x")
            FixedText("100")
        }
    }

    private var blank: some View {
        HStack(spacing: termHSpacing) {
            FixedText("=")
            VStack(spacing: fractionVSpacing) {
                animatingNumber(
                    data.actualProductMass,
                    show: showActualData,
                    formatter: { $0.str(decimals: 2) }
                )
                Rectangle()
                    .frame(width: 100, height: 2)
                PlaceholderTerm(
                    value: showTheoreticalData ? data.theoreticalProductMass.str(decimals: 2) : nil,
                    emphasise: true
                )
            }
        }
    }

    private func animatingNumber(
        _ equation: Equation,
        show: Bool,
        formatter: @escaping (CGFloat) -> String
    ) -> some View {
        AnimatingNumberPlaceholder(
            showTerm: show,
            progress: reactionProgress,
            equation: equation,
            formatter: formatter
        )
        .frame(width: EquationSizing.boxWidth, height: EquationSizing.boxHeight)
    }
}

private struct TermView: View {
    let base: String
    let subTerm: TextLine
    let underlineTerm: String?

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                FixedText(base)
                    .font(.system(size: EquationSizing.fontSize))
                FixedText(subTerm.asString)
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
}

struct LimitingReagentEquationData {

    let reaction: LimitingReagentReaction

    let volume: CGFloat

    let limitingReactantMoles: CGFloat
    let limitingReactantMolarity: CGFloat

    let neededExcessReactantMoles: CGFloat
    let theoreticalProductMass: CGFloat
    let theoreticalProductMoles: CGFloat

    let reactingExcessReactantMoles: Equation
    let reactingExcessReactantMass: Equation

    let actualProductMass: Equation
    let actualProductMoles: Equation

    let yield: Equation
}

struct LimitingReagentEquationView_Previews: PreviewProvider {
    static var previews: some View {
        SizedLimitingReagentEquationView(
            data: previewData,
            reactionProgress: 0,
            showTheoreticalData: false,
            showActualData: false,
            highlights: .init()
        )
        .border(Color.black)
        .frame(width: NaturalWidth, height: NaturalHeight)
        .border(Color.red)
        .previewLayout(.sizeThatFits)
    }

    private static let previewData = LimitingReagentEquationData(
        reaction: .availableReactions.first!,
        volume: 0.1,
        limitingReactantMoles: 0.02,
        limitingReactantMolarity: 0.2,
        neededExcessReactantMoles: 0.04,
        theoreticalProductMass: 2.68,
        theoreticalProductMoles: 0.02,
        reactingExcessReactantMoles: ConstantEquation(value: 0.02),
        reactingExcessReactantMass: ConstantEquation(value: 1.68),
        actualProductMass: ConstantEquation(value: 1.34),
        actualProductMoles: ConstantEquation(value: 0.01),
        yield: ConstantEquation(value: 0.5)
    )
}
