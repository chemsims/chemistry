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

    private let spacing: CGFloat = 26

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            VStack(alignment: .leading, spacing: spacing)  {
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
            }
            .background(Color.white.padding(-5))
            .colorMultiply(model.highlightedElements.colorMultiply(for: .integrationRateDefinitions))


            VStack(alignment: .leading, spacing: spacing)  {
                RateComparison(
                    forwardRate: model.forwardRate.rate,
                    reverseRate: model.reverseRate.rate,
                    time: model.currentTime
                )

                KComparison(
                    k: model.selectedReaction.equilibriumConstant,
                    kForward: model.selectedReaction.forwardRateConstant,
                    kReverse: model.selectedReaction.reverseRateConstant
                )
            }
            .background(Color.white.padding(-5))
            .colorMultiply(model.highlightedElements.colorMultiply(for: .integrationRateValues))
        }
        .font(.system(size: EquationSizing.fontSize))
        .id(model.selectedReaction.rawValue)
        .transition(.identity)
        .minimumScaleFactor(0.75)
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
                rateSubscript: rateSubscript,
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
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text(label))
    }

    private func moleculeTerm(
        _ term: ReactionRateDefinition.Part
    ) -> some View {
        HStack(spacing: 0) {
            FixedText("[\(term.molecule.rawValue)]")
            if term.coefficient != 1 {
                FixedText("\(term.coefficient)")
                    .font(.system(size: EquationSizing.subscriptFontSize))
                    .offset(y: -10)
            }
        }
    }

    private var label: String {
        func molecule(_ part: ReactionRateDefinition.Part) -> String {
            let coeff = part.coefficient
            let coeffString = coeff == 1 ? "" : " to the power of \(coeff)"
            return "concentration of \(part.molecule.rawValue)\(coeffString)"
        }
        let moleculeString = "\(molecule(reaction.firstMolecule)) times \(molecule(reaction.secondMolecule))"
        return "Rate \(rateSubscript) equals k \(rateSubscript) times \(moleculeString)"
    }
}

private struct RateDefinitionFilled: View {

    let reaction: ReactionRateDefinition
    let rateSubscript: String
    let time: CGFloat

    var body: some View {
        HStack(spacing: equationHSpacing) {
            rate
            Equals()
            FixedText(reaction.k.str(decimals: 2))
                .foregroundColor(.orangeAccent)
                .accessibility(label: Text("k \(rateSubscript)"))
                .accessibility(value: Text(reaction.k.str(decimals: 2)))
            term(reaction.firstMolecule)
            term(reaction.secondMolecule)
        }
    }

    private var rate: some View {
        AnimatingNumber(
            x: time,
            equation: reaction.rate,
            formatter: tripleDecimalFormatter
        )
        .frame(width: rateLhsWidth, height: EquationSizing.boxHeight)
        .foregroundColor(.orangeAccent)
        .font(.system(size: EquationSizing.tripleDecimalFontSize))
        .accessibility(label: Text("rate \(rateSubscript)"))
    }

    private func term(_ part: ReactionRateDefinition.Part) -> some View {
        HStack(spacing: 0) {
            FixedText("(")
                .accessibility(hidden: true)

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
            .accessibility(label: Text("concentration of \(part.molecule.rawValue)"))

            FixedText(")")
                .accessibility(hidden: true)
            if part.coefficient != 1 {
                FixedText("\(part.coefficient)")
                    .font(.system(size: EquationSizing.subscriptFontSize))
                    .offset(y: -10)
                    .accessibility(label: Text("to the power of \(part.coefficient)"))
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
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text("rate f equals rate r"))
    }

    private var filled: some View {
        HStack(spacing: equationHSpacing) {
            number(forwardRate, "f")
            RatioComparisonSymbol(
                top: forwardRate,
                bottom: reverseRate,
                time: time
            )
            number(reverseRate, "r")
        }
    }

    private func number(_ equation: Equation, _ rateSubscript: String) -> some View {
        AnimatingNumber(
            x: time,
            equation: equation,
            formatter: tripleDecimalFormatter
        )
        .frame(width: rateLhsWidth, height: EquationSizing.boxHeight)
        .foregroundColor(.orangeAccent)
        .font(.system(size: EquationSizing.tripleDecimalFontSize))
        .accessibility(label: Text("rate \(rateSubscript)"))
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
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text("K equals k f divide by k r"))
    }

    private var filled: some View {
        HStack(spacing: equationHSpacing) {
            filledText(value: k.str(decimals: 2), label: "K")
                .frame(width: rateLhsWidth)
            Equals()
            filledText(value: kForward.str(decimals: 2), label: "k f")
            FixedText("/")
                .accessibility(label: Text("divide by"))
            filledText(value: kReverse.str(decimals: 2), label: "k r")
        }
    }

    private func filledText(value: String, label: String) -> some View {
        FixedText(value)
            .accessibility(label: Text(label))
            .accessibility(value: Text(value))
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
            let lRounded = l.rounded(decimals: 3)
            let rRounded = r.rounded(decimals: 3)

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

private let NaturalWidth: CGFloat = 382
private let NaturalHeight: CGFloat = 430

private func tripleDecimalFormatter(_ value: CGFloat) -> String {
    if value == 0 {
        return "0"
    }
    return value.str(decimals: 3)
}

struct IntegrationEquationView_Previews: PreviewProvider {
    static var previews: some View {
        SizedIntegrationEquationView(model: IntegrationViewModel())
            .border(Color.red)
            .frame(width: NaturalWidth, height: NaturalHeight)
            .previewLayout(.fixed(width: NaturalWidth, height: NaturalHeight))
    }
}
