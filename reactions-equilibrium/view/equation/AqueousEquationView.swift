//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AqueousEquationView: View {

    let equations: BalancedReactionEquations
    let quotient: Equation
    let convergedQuotient: CGFloat
    let currentTime: CGFloat

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
                equations: equations,
                quotient: quotient,
                convergedQuotient: convergedQuotient,
                currentTime: currentTime
            )
        }
        .frame(width: maxWidth, height: maxHeight)
    }
}

private struct UnscaledAqueousEquationView: View {
    let equations: BalancedReactionEquations
    let quotient: Equation
    let convergedQuotient: CGFloat
    let currentTime: CGFloat

    var body: some View {
        VStack {
            HStack(spacing: 40) {
                QuotientDefinitionView(coefficients: equations.coefficients)
                Spacer()
                QuotientEqualsKView()
            }
            HStack(spacing: 30) {
                FilledQuotientDefinitionView(
                    equations: equations,
                    quotient: quotient,
                    currentTime: currentTime
                )

                FilledQuotientKView(
                    quotient: quotient,
                    convergedQuotient: convergedQuotient,
                    currentTime: currentTime
                )
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
            fraction
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
    var body: some View {
        HStack(spacing: 2) {
            FixedText("Q")
                .frame(width: EquationSizing.boxWidth)
            FixedText("=")
                .frame(width: 22)
            FixedText("K")
                .frame(width: EquationSizing.boxWidth)
        }
    }
}

private struct FilledQuotientDefinitionView: View {

    let equations: BalancedReactionEquations
    let quotient: Equation
    let currentTime: CGFloat

    var body: some View {
        HStack(spacing: 4) {
            animatingTerm(equation: quotient, formatter: formatQuotient)
            FixedText("=")
            fraction
        }
        .minimumScaleFactor(0.5)
    }

    private var fraction: some View {
        VStack(spacing: 0) {
            HStack(spacing: 3) {
                term(equations.productC, 2, coefficient: equations.coefficients.productC)
                term(equations.productD, 2, coefficient: equations.coefficients.productD)
            }
            Rectangle()
                .frame(width:  180, height: 1)
            HStack(spacing: 3) {
                term(equations.reactantA, 2, coefficient: equations.coefficients.reactantA)
                term(equations.reactantB, 2, coefficient: equations.coefficients.reactantB)
            }
        }
    }

    private func term(
        _ equation: Equation,
        _ decimals: Int,
        coefficient: Int
    ) -> some View {
        HStack(spacing: 2) {
            animatingTerm(equation: equation) {
                "(\($0.str(decimals: decimals)))"
            }

            FixedText("\(coefficient)")
                .offset(y: -10)
                .font(.system(size: EquationSizing.subscriptFontSize))
                .opacity(coefficient == 1 ? 0 : 1)
                .animation(nil)
                .frame(width: 15)
        }
    }

    private func animatingTerm(
        equation: Equation,
        formatter: @escaping (CGFloat) -> String
    ) -> some View {
        AnimatingNumber(
            x: currentTime,
            equation: equation,
            formatter: formatter
        )
        .frame(width: EquationSizing.boxWidth, height: EquationSizing.boxHeight)
    }
}

private struct FilledQuotientKView: View {

    let quotient: Equation
    let convergedQuotient: CGFloat
    let currentTime: CGFloat

    var body: some View {
        HStack(spacing: 2) {
            AnimatingNumber(
                x: currentTime,
                equation: quotient,
                formatter: formatQuotient
            )
            .frame(width: EquationSizing.boxWidth, height: EquationSizing.boxHeight)
            .minimumScaleFactor(0.5)

            AnimatingNumber(
                x: currentTime,
                equation: quotient,
                formatter: formatEquals
            )
            .frame(width: 22, height: 30)

            FixedText("\(convergedQuotient.str(decimals: 2))")
                .frame(width: EquationSizing.boxWidth)
                .minimumScaleFactor(0.8)
        }
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

private let NaturalHeight: CGFloat = 200
private let NaturalWidth: CGFloat = 480

struct AqueousEquationView_Previews: PreviewProvider {
    static var previews: some View {
        UnscaledAqueousEquationView(
            equations: reverse,
            quotient: ReactionQuotientEquation(equations: reverse),
            convergedQuotient: 0.14,
            currentTime: 14
        )
        .previewLayout(.fixed(width: NaturalWidth, height: NaturalHeight))
        .border(Color.black)
    }

    private static let reverse = BalancedReactionEquations(
        forwardReaction: equations,
        reverseInput: ReverseReactionInput(c0: 0.4, d0: 0.4, startTime: 21, convergenceTime: 30)
    )

    private static let equations = BalancedReactionEquations(
        coefficients: BalancedReactionCoefficients(
            reactantA: 2,
            reactantB: 2,
            productC: 1,
            productD: 4
        ),
        equilibriumConstant: 2,
        a0: 0.3,
        b0: 0.3,
        convergenceTime: 20
    )
}

private func formatQuotient(_ quotient: CGFloat) -> String {
    if (quotient >= 100) {
        return quotient.str(decimals: 0)
    } else {
        return quotient.str(decimals: 2)
    }
}
