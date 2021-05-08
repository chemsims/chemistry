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
                model: model,
                reaction: model.forwardRate,
                rateSubscript: "f"
            )

            RateDefinition(
                model: model,
                reaction: model.reverseRate,
                rateSubscript: "r"
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

    let model: IntegrationViewModel
    let reaction: ReactionRateDefinition
    let rateSubscript: String

    var body: some View {
        VStack(alignment: .leading, spacing: equationVSpacing) {
            RateDefinitionBlank(
                reaction: model.forwardRate,
                rateSubscript: rateSubscript
            )
            RateDefinitionFilled(
                reaction: reaction,
                time: model.currentTime
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
            FixedText("=")
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
            FixedText("=")
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
            FixedText("=")
            Rate(rateSubscript: "r")
        }
    }

    private var filled: some View {
        HStack(spacing: equationHSpacing) {
            number(forwardRate)
            FixedText("=")
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
            FixedText("=")
            K(kSubscript: "f")
            FixedText("/")
            K(kSubscript: "r")
        }
    }

    private var filled: some View {
        HStack(spacing: equationHSpacing) {
            FixedText(k.str(decimals: 2))
                .frame(width: rateLhsWidth)
            FixedText("=")
            FixedText(kForward.str(decimals: 2))
            FixedText("/")
            FixedText(kReverse.str(decimals: 2))
        }
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

private let rateLhsWidth: CGFloat = 70
private let equationHSpacing: CGFloat = 7
private let equationVSpacing: CGFloat = 5

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
