//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AqueousEquationView: View {

    let showTerms: Bool
    let equations: NewBalancedReactionEquation
    let quotient: Equation
    let convergedQuotient: CGFloat
    let currentTime: CGFloat

    let highlightedElements: HighlightedElements<AqueousScreenElement>

    let maxWidth: CGFloat
    let maxHeight: CGFloat

    var body: some View {
        ScaledView(
            naturalWidth: NaturalWidth,
            naturalHeight: NaturalHeight,
            maxWidth: maxWidth,
            maxHeight: maxHeight
        ) {
            UnscaledAqueousEquationView(
                showTerms: showTerms,
                equations: equations,
                quotient: quotient,
                convergedQuotient: convergedQuotient,
                currentTime: currentTime,
                highlightedElements: highlightedElements
            )
        }
        .frame(width: maxWidth, height: maxHeight)
    }
}

private struct UnscaledAqueousEquationView: View {

    let showTerms: Bool
    let equations: NewBalancedReactionEquation
    let quotient: Equation
    let convergedQuotient: CGFloat
    let currentTime: CGFloat
    let highlightedElements: HighlightedElements<AqueousScreenElement>

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 40) {
                QuotientDefinitionView(coefficients: equations.coefficients)
                    .colorMultiply(
                        highlightedElements.colorMultiply(for: .quotientToConcentrationDefinition)
                    )
                    .background(
                        Color.white
                            .padding(.trailing, -15)
                            .padding(.leading, -10)
                            .padding(.vertical, -10)
                            .colorMultiply(
                                highlightedElements.colorMultiply(for: .quotientToConcentrationDefinition)
                            )
                    )

                Spacer()
                    .frame(height: 10)

                QuotientEqualsKView(
                    currentTime: currentTime,
                    quotient: quotient,
                    convergedQuotient: convergedQuotient
                )
                .colorMultiply(
                    highlightedElements.colorMultiply(for: .quotientToConcentrationDefinition)
                )
                .background(
                    Color.white
                        .padding(-20)
                        .colorMultiply(
                            highlightedElements.colorMultiply(for: .quotientToEquilibriumConstantDefinition)
                        )
                )

            }
            HStack(spacing: 30) {
                FilledQuotientDefinitionView(
                    showTerms: showTerms,
                    equations: equations,
                    quotient: quotient,
                    currentTime: currentTime
                )
                .colorMultiply(highlightedElements.colorMultiply(for: nil))
                Spacer()
                FilledQuotientKView(
                    showTerms: showTerms,
                    quotient: quotient,
                    convergedQuotient: convergedQuotient,
                    currentTime: currentTime
                )
                .colorMultiply(highlightedElements.colorMultiply(for: nil))
            }
        }
        .font(.system(size: EquationSizing.fontSize))
        .lineLimit(1)
        .minimumScaleFactor(1)
    }
}

private struct QuotientDefinitionView: View {

    let coefficients: BalancedReactionCoefficients

    var body: some View {
        HStack(spacing: 4) {
            FixedText("Q")
                .frame(width: EquationSizing.boxWidth)
            FixedText("=")
                .frame(width: 22)
            fraction
                .frame(width: 150)
        }
    }

    private var fraction: some View {
        VStack(spacing: 2) {
            HStack(spacing: 8) {
                term("C", coefficient: coefficients.productC)
                term("D", coefficient: coefficients.productD)
            }
            Rectangle()
                .frame(width: 130, height: 1)
            HStack(spacing: 8) {
                term("A", coefficient: coefficients.reactantA)
                term("B", coefficient: coefficients.reactantB)
            }
        }
    }

    private func term(_ name: String, coefficient: Int) -> some View {
        HStack(spacing: 2) {
            FixedText("[\(name)]")
            FixedText("\(coefficient)")
                .offset(y: -10)
                .font(.system(size: EquationSizing.subscriptFontSize))
                .opacity(coefficient == 1 ? 0 : 1)
                .frame(width: 15)
                .animation(nil)
        }
    }
}
private struct QuotientEqualsKView: View {

    let currentTime: CGFloat
    let quotient: Equation
    let convergedQuotient: CGFloat

    var body: some View {
        HStack(spacing: 2) {
            FixedText("Q")
                .frame(width: EquationSizing.boxWidth)

            QuotientEqualitySign(
                currentTime: currentTime,
                quotient: quotient,
                convergedQuotient: convergedQuotient
            )

            FixedText("K")
                .frame(width: EquationSizing.boxWidth)
        }
    }
}

private struct FilledQuotientDefinitionView: View {

    let showTerms: Bool
    let equations: NewBalancedReactionEquation
    let quotient: Equation
    let currentTime: CGFloat

    var body: some View {
        HStack(spacing: 4) {
            AnimatingNumberOrPlaceholder(
                showTerm: showTerms,
                currentTime: currentTime,
                equation: quotient,
                formatter: formatQuotient
            )
            FixedText("=")
            fraction
        }
        .minimumScaleFactor(0.5)
    }

    private var fraction: some View {
        VStack(spacing: 0) {
            HStack(spacing: 3) {
                concentration(equations.concentration.productC, coefficient: equations.coefficients.productC)
                concentration(equations.concentration.productD, coefficient: equations.coefficients.productD)
            }
            Rectangle()
                .frame(width:  180, height: 1)
            HStack(spacing: 3) {
                concentration(equations.concentration.reactantA, coefficient: equations.coefficients.reactantA)
                concentration(equations.concentration.reactantB, coefficient: equations.coefficients.reactantB)
            }
        }
    }

    private func concentration(
        _ equation: Equation,
        coefficient: Int
    ) -> some View {
        HStack(spacing: 2) {
            AnimatingNumberOrPlaceholder(
                showTerm: showTerms,
                currentTime: currentTime,
                equation: equation,
                formatter: { "(\($0.str(decimals: 2)))" }
            )

            FixedText("\(coefficient)")
                .offset(y: -10)
                .font(.system(size: EquationSizing.subscriptFontSize))
                .opacity(coefficient == 1 ? 0 : 1)
                .animation(nil)
                .frame(width: 15)
        }
    }

}

private struct FilledQuotientKView: View {

    let showTerms: Bool
    let quotient: Equation
    let convergedQuotient: CGFloat
    let currentTime: CGFloat

    var body: some View {
        HStack(spacing: 2) {
            AnimatingNumberOrPlaceholder(
                showTerm: showTerms,
                currentTime: currentTime,
                equation: quotient,
                formatter: formatQuotient
            )

            QuotientEqualitySign(
                currentTime: currentTime,
                quotient: quotient,
                convergedQuotient: convergedQuotient
            )

            AnimatingNumberOrPlaceholder(
                showTerm: showTerms,
                currentTime: currentTime,
                equation: ConstantEquation(value: convergedQuotient),
                formatter: { $0.str(decimals: 2) }
            )
        }
    }
}

private struct QuotientEqualitySign: View {

    let currentTime: CGFloat
    let quotient: Equation
    let convergedQuotient: CGFloat

    var body: some View {
        AnimatingNumber(
            x: currentTime,
            equation: quotient,
            formatter: formatEquals
        )
        .frame(width: 22, height: 30)
    }

    private func formatEquals(at quotient: CGFloat) -> String {
        let roundedQuotient = quotient.rounded(decimals: 2)
        let roundedConverged = convergedQuotient.rounded(decimals: 2)

        if roundedQuotient > roundedConverged {
            return ">"
        } else if roundedQuotient < roundedConverged {
            return "<"
        }
        return "="
    }
}

private struct AnimatingNumberOrPlaceholder: View {

    let showTerm: Bool
    let currentTime: CGFloat
    let equation: Equation
    let formatter: (CGFloat) -> String

    var body: some View {
        if showTerm {
            AnimatingNumber(
                x: currentTime,
                equation: equation,
                formatter: formatter
            )
            .frame(
                width: EquationSizing.boxWidth,
                height: EquationSizing.boxHeight
            )
            .minimumScaleFactor(0.5)
            .foregroundColor(.orangeAccent)
        } else {
            PlaceholderTerm(value: nil)
                .frame(
                    width: EquationSizing.boxWidth,
                    height: EquationSizing.boxHeight
                )
        }
    }
}

private let NaturalHeight: CGFloat = 190
private let NaturalWidth: CGFloat = 590

private func formatQuotient(_ quotient: CGFloat) -> String {
    if (quotient >= 100) {
        return quotient.str(decimals: 0)
    } else {
        return quotient.str(decimals: 2)
    }
}


struct AqueousEquationView_Previews: PreviewProvider {
    static var previews: some View {
        UnscaledAqueousEquationView(
            showTerms: true,
            equations: equations,
            quotient: ReactionQuotientEquation(equations: equations),
            convergedQuotient: 0.14,
            currentTime: 14,
            highlightedElements: HighlightedElements(
                elements:  [AqueousScreenElement.quotientToEquilibriumConstantDefinition]
            )
        )
        .border(Color.black)
        .frame(width: NaturalWidth, height: NaturalHeight)
        .border(Color.red)
        .previewLayout(.fixed(width: NaturalWidth + 30, height: NaturalHeight + 30))
        .frame(width: NaturalWidth + 30, height: NaturalHeight + 30)
        .background(Color.gray.opacity(0.5))
    }

    private static let equations = NewBalancedReactionEquation(
        coefficients: BalancedReactionCoefficients(builder: { _ in 1 }),
        equilibriumConstant: 1,
        initialConcentrations: MoleculeValue(builder: { _ in 0.5}),
        startTime: 0,
        equilibriumTime: 10,
        previous: nil
    )
}
