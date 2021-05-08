//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct IntegrationEquationView: View {

    let model: IntegrationViewModel

    var body: some View {
        GeometryReader { geo in
            ScaledView(
                naturalWidth: NaturalWidth,
                naturalHeight: NaturalHeight,
                maxWidth: geo.size.width,
                maxHeight: geo.size.height
            ) {
                SizedIntegrationEquationView(model: model)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

private struct SizedIntegrationEquationView: View {
    @ObservedObject var model: IntegrationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 26) {
            RateDefinition(
                reaction: model.forwardRate,
                rateSubscript: "f",
                time: model.currentTime
            )

            RateDefinition(
                reaction: model.reverseRate,
                rateSubscript: "r",
                time: model.currentTime
            )

            RateComparison(
                forwardRate: model.forwardRate.rate,
                reverseRate: model.reverseRate.rate,
                time: model.currentTime
            )

            KComparison(
                k: model.selectedReaction.equilibriumConstant,
                kForward: model.kf,
                kReverse: model.kr
            )
        }

        .font(.system(size: EquationSizing.fontSize))
    }
}

private struct RateDefinition: View {

    let reaction: ReactionRateDefinition
    let rateSubscript: String
    let time: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: equationVSpacing) {
            RateDefinitionBlank(
                reaction: reaction,
                rateSubscript: rateSubscript
            )
            RateDefinitionFilled(
                reaction: reaction,
                time: time
            )
        }
    }
}

private struct RateDefinitionBlank: View {

    let reaction: ReactionRateDefinition
    let rateSubscript: String

    var body: some View {
        HStack(spacing: equationHSpacing) {
            Rate(rateSubscript: rateSubscript)
            Equals()
            HStack(spacing: 0) {
                K(kSubscript: rateSubscript)
                moleculeTerm(reaction.firstMolecule)
                moleculeTerm(reaction.secondMolecule)
            }

        }
    }

    private func moleculeTerm(
        _ term: ReactionRateDefinition.Part
    ) -> some View {
        HStack(spacing: 0) {
            FixedText("[\(term.molecule.rawValue)]")
            FixedText("\(term.coefficient)")
                .font(.system(size: EquationSizing.subscriptFontSize))
                .offset(y: -10)
                .opacity(term.coefficient == 1 ? 0 : 1)
        }
        .frame(width: 55)
    }
}

private struct RateDefinitionFilled: View {

    let reaction: ReactionRateDefinition
    let time: CGFloat

    var body: some View {
        HStack(spacing: equationHSpacing) {
            rate
            Equals()
            FixedText(reaction.k.str(decimals: 2))
                .foregroundColor(.orangeAccent)
            term(reaction.firstMolecule)
            term(reaction.secondMolecule)
        }
    }

    private var rate: some View {
        AnimatingNumber(
            x: time,
            equation: reaction.rate,
            formatter: { $0.str(decimals: 2) }
        )
        .frame(width: rateLhsWidth, height: EquationSizing.boxHeight)
        .foregroundColor(.orangeAccent)
    }

    private func term(_ part: ReactionRateDefinition.Part) -> some View {
        HStack(spacing: 0) {
            FixedText("(")
            AnimatingNumber(
                x: time,
                equation: part.concentration,
                formatter: { $0.str(decimals: 2) }
            )
            .frame(
                width: EquationSizing.boxWidth,
                height: EquationSizing.boxHeight
            )
            .foregroundColor(.orangeAccent)
            FixedText(")")
            if part.coefficient != 1 {
                FixedText("\(part.coefficient)")
                    .font(.system(size: EquationSizing.subscriptFontSize))
                    .offset(y: -10)
            }
        }
    }
}

private struct RateComparison: View {

    let forwardRate: Equation
    let reverseRate: Equation
    let time: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: equationVSpacing) {
            definition
            filled
        }
    }

    private var definition: some View {
        HStack(spacing: equationHSpacing) {
            Rate(rateSubscript: "f")
            RatioComparisonSymbol(
                top: forwardRate,
                bottom: reverseRate,
                time: time
            )
            Rate(rateSubscript: "r")
        }
    }

    private func formatEquals(_ ratio: CGFloat) -> String {
        if ratio < 1 {
            return "<"
        } else if ratio > 1 {
            return ">"
        }
        return "="
    }

    private var equalsEquation: Equation {
        OperatorEquation(lhs: forwardRate, rhs: reverseRate) { (l, r) in
            guard r != 0 else {
                return 0
            }
            return l.rounded(decimals: 2) / r.rounded(decimals: 2)
        }
    }

    private var filled: some View {
        HStack(spacing: equationHSpacing) {
            number(forwardRate)
            Equals()
            number(reverseRate)
        }
    }

    private func number(_ equation: Equation) -> some View {
        AnimatingNumber(
            x: time,
            equation: equation,
            formatter: { $0.str(decimals: 2) }
        )
        .frame(width: rateLhsWidth, height: EquationSizing.boxHeight)
        .foregroundColor(.orangeAccent)
    }
}

private struct KComparison: View {

    let k: CGFloat
    let kForward: CGFloat
    let kReverse: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: equationVSpacing) {
            definition
            filled
        }
    }

    private var definition: some View {
        HStack(spacing: equationHSpacing) {
            FixedText("K")
                .frame(width: rateLhsWidth)
            Equals()
            K(kSubscript: "f")
            FixedText("/")
            K(kSubscript: "r")
        }
    }

    private var filled: some View {
        HStack(spacing: equationHSpacing) {
            FixedText(k.str(decimals: 2))
                .frame(width: rateLhsWidth)
            Equals()
            FixedText(kForward.str(decimals: 2))
            FixedText("/")
            FixedText(kReverse.str(decimals: 2))
        }
    }
}

private struct RatioComparisonSymbol: View {

    let top: Equation
    let bottom: Equation
    let time: CGFloat

    var body: some View {
        AnimatingNumber(
            x: time,
            equation: compareEquation,
            formatter: formatEquals
        )
        .frame(width: equalsWidth, height: 30)
    }

    private var compareEquation: Equation {
        OperatorEquation(lhs: top, rhs: bottom) { (l, r) in
            let lRounded = l.rounded(decimals: 2)
            let rRounded = r.rounded(decimals: 2)

            if lRounded < rRounded {
                return -1
            } else if lRounded > rRounded {
                return 1
            }
            return 0
        }
    }

    private func formatEquals(_ ratio: CGFloat) -> String {
        if ratio < 0 {
            return "<"
        } else if ratio > 0 {
            return ">"
        }
        return "="
    }
}

private struct Rate: View {
    let rateSubscript: String

    var body: some View {
        SubscriptTerm(base: "Rate", subscriptTerm: rateSubscript)
            .frame(width: rateLhsWidth)
    }
}

private struct K: View {
    let kSubscript: String

    var body: some View {
        SubscriptTerm(base: "k", subscriptTerm: kSubscript)
            .frame(width: 30)
    }
}

private struct SubscriptTerm: View {
    let base: String
    let subscriptTerm: String

    var body: some View {
        HStack(spacing: 0) {
            FixedText(base)
            FixedText(subscriptTerm)
                .font(.system(size: EquationSizing.subscriptFontSize))
                .offset(y: 10)
        }
    }
}

private struct Equals: View {
    var body: some View {
        FixedText("=")
            .frame(width: equalsWidth)
    }
}

private let rateLhsWidth: CGFloat = 70
private let equationHSpacing: CGFloat = 7
private let equationVSpacing: CGFloat = 5
private let equalsWidth: CGFloat = 18

private let NaturalWidth: CGFloat = 360
private let NaturalHeight: CGFloat = 430

struct IntegrationEquationView_Previews: PreviewProvider {
    static var previews: some View {
        SizedIntegrationEquationView(model: IntegrationViewModel())
            .border(Color.red)
            .frame(width: NaturalWidth, height: NaturalHeight)
            .previewLayout(.fixed(width: NaturalWidth, height: NaturalHeight))
    }
}
