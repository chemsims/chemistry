//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AqueousEquationView: View {

    let equations: BalancedReactionEquations
    let quotient: Equation
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
                currentTime: currentTime
            )
        }
        .frame(width: maxWidth, height: maxHeight)
    }
}

private struct UnscaledAqueousEquationView: View {
    let equations: BalancedReactionEquations
    let quotient: Equation
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

                FilledQuotientKView(quotient: quotient, currentTime: currentTime)
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
            term(quotient, 2, withParens: false)
            FixedText("=")
            fraction
        }
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
        withParens: Bool = true,
        coefficient: Int? = nil
    ) -> some View {
        HStack(spacing: 2) {
            AnimatingNumber(
                x: currentTime,
                equation: equation,
                formatter: {
                    let asString = $0.str(decimals: decimals)
                    return withParens ? "(\(asString))" : asString
                }
            )
            .frame(width: EquationSizing.boxWidth, height: EquationSizing.boxHeight)

            if (coefficient != nil) {
                FixedText("\(coefficient!)")
                    .offset(y: -10)
                    .font(.system(size: EquationSizing.subscriptFontSize))
                    .opacity(coefficient == 1 ? 0 : 1)
                    .animation(nil)
                    .frame(width: 15)
            }
        }
        .minimumScaleFactor(0.5)
    }
}

private struct FilledQuotientKView: View {

    let quotient: Equation
    let currentTime: CGFloat

    var body: some View {
        HStack(spacing: 2) {
            AnimatingNumber(
                x: currentTime,
                equation: quotient,
                formatter: { $0.str(decimals: 2)}
            )
            .frame(width: EquationSizing.boxWidth, height: EquationSizing.boxHeight)
            .minimumScaleFactor(0.5)

            FixedText("=")

            AnimatingNumber(
                x: currentTime,
                equation: quotient,
                formatter: { $0.str(decimals: 2)}
            )
            .frame(width: EquationSizing.boxWidth, height: EquationSizing.boxHeight)
            .minimumScaleFactor(0.5)
        }
    }
}

private let NaturalHeight: CGFloat = 200
private let NaturalWidth: CGFloat = 480

struct AqueousEquationView_Previews: PreviewProvider {
    static var previews: some View {
        UnscaledAqueousEquationView(
            equations: equations,
            quotient: ReactionQuotientEquation(equations: equations),
            currentTime: 10
        )
        .previewLayout(.fixed(width: NaturalWidth, height: NaturalHeight))
        .border(Color.black)
    }

    private static let equations = BalancedReactionEquations(
        coefficients: BalancedReactionCoefficients(
            reactantA: 2,
            reactantB: 2,
            productC: 1,
            productD: 4
        ),
        equilibriumConstant: 1,
        a0: 0.5,
        b0: 0.4,
        convergenceTime: 20
    )
}
