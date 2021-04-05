//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AqueousEquationView: View {

    let showTerms: Bool
    let equations: MoleculeValue<Equation>
    let coefficients: MoleculeValue<Int>
    let quotient: Equation
    let convergedQuotient: CGFloat
    let currentTime: CGFloat

    let kTerm: String
    let formatElementName: (String) -> String
    let generalElementHighlight: Color
    let quotientToConcentrationDefinitionHighlight: Color
    let quotientToEquilibriumConstantDefinitionHighlight: Color

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
                coefficients: coefficients,
                quotient: quotient,
                convergedQuotient: convergedQuotient,
                currentTime: currentTime,
                kTerm: kTerm,
                formatElementName: formatElementName,
                generalElementHighlight: generalElementHighlight,
                quotientToCHighlight: quotientToConcentrationDefinitionHighlight,
                quotientToEqHighlight: quotientToEquilibriumConstantDefinitionHighlight
            )
        }
        .frame(width: maxWidth, height: maxHeight)
    }
}

private struct UnscaledAqueousEquationView: View {

    let showTerms: Bool
    let equations: MoleculeValue<Equation>
    let coefficients: MoleculeValue<Int>
    let quotient: Equation
    let convergedQuotient: CGFloat
    let currentTime: CGFloat

    let kTerm: String
    let formatElementName: (String) -> String

    let generalElementHighlight: Color
    let quotientToCHighlight: Color
    let quotientToEqHighlight: Color

    var body: some View {
        VStack(spacing: 1) {
            HStack(spacing: 40) {
                QuotientDefinitionView(
                    coefficients: coefficients,
                    formatName: formatElementName
                )
                    .colorMultiply(
                        quotientToCHighlight
                    )
                    .background(
                        Color.white
                            .padding(.trailing, -15)
                            .padding(.leading, -10)
                            .padding(.vertical, -10)
                            .colorMultiply(
                                quotientToCHighlight
                            )
                    )

                Spacer()
                    .frame(height: 10)

                QuotientEqualsKView(
                    kTerm: kTerm,
                    currentTime: currentTime,
                    quotient: quotient,
                    convergedQuotient: convergedQuotient
                )
                .colorMultiply(
                    quotientToCHighlight
                )
                .background(
                    Color.white
                        .padding(-20)
                        .colorMultiply(
                            quotientToEqHighlight
                        )
                )

            }
            HStack(spacing: 30) {
                FilledQuotientDefinitionView(
                    showTerms: showTerms,
                    equations: equations,
                    coefficients: coefficients,
                    quotient: quotient,
                    currentTime: currentTime
                )
                .colorMultiply(generalElementHighlight)
                Spacer()
                FilledQuotientKView(
                    showTerms: showTerms,
                    quotient: quotient,
                    convergedQuotient: convergedQuotient,
                    currentTime: currentTime
                )
                .colorMultiply(generalElementHighlight)
            }
        }
        .font(.system(size: EquationSizing.fontSize))
        .lineLimit(1)
        .minimumScaleFactor(1)
    }
}

private struct QuotientDefinitionView: View {

    let coefficients: BalancedReactionCoefficients
    let formatName: (String) -> String

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
        VStack(spacing: 4) {
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
            FixedText(formatName(name))
            FixedText("\(coefficient)")
                .offset(y: -10)
                .font(.system(size: EquationSizing.subscriptFontSize))
                .opacity(coefficient == 1 ? 0 : 1)
                .frame(width: 15)
                .animation(nil)
        }
        .frame(width: EquationSizing.boxWidth, height: EquationSizing.boxHeight)
    }
}
private struct QuotientEqualsKView: View {

    let kTerm: String
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

            FixedText(kTerm)
                .frame(width: EquationSizing.boxWidth)
        }
    }
}

private struct FilledQuotientDefinitionView: View {

    let showTerms: Bool
    let equations: MoleculeValue<Equation>
    let coefficients: MoleculeValue<Int>
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
        VStack(spacing: 4) {
            HStack(spacing: 3) {
                concentration(.C)
                concentration(.D)
            }
            Rectangle()
                .frame(width:  170, height: 1)
            HStack(spacing: 3) {
                concentration(.A)
                concentration(.B)
            }
        }
    }

    private func concentration(
        _ molecule: AqueousMolecule
    ) -> some View {
        HStack(spacing: 2) {
            AnimatingNumberOrPlaceholder(
                showTerm: showTerms,
                currentTime: currentTime,
                equation: equations.value(for: molecule),
                formatter: { "(\($0.str(decimals: 2)))" }
            )

            FixedText("\(coefficients.value(for: molecule))")
                .offset(y: -10)
                .font(.system(size: EquationSizing.subscriptFontSize))
                .opacity(coefficients.value(for: molecule) == 1 ? 0 : 1)
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

struct AnimatingNumberOrPlaceholder: View {

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

private let NaturalHeight: CGFloat = 222
private let NaturalWidth: CGFloat = 570

private func formatQuotient(_ quotient: CGFloat) -> String {
    if (quotient >= 100) {
        return quotient.str(decimals: 0)
    } else {
        return quotient.str(decimals: 2)
    }
}


struct AqueousEquationView_Previews: PreviewProvider {
    static var previews: some View {
        AqueousEquationView(
            showTerms: true,
            equations: equations.concentration,
            coefficients: equations.coefficients,
            quotient: ReactionQuotientEquation(equations: equations),
            convergedQuotient: 0.14,
            currentTime: 14,
            kTerm: "K",
            formatElementName: {
                "P\($0.lowercased())"
            },
            generalElementHighlight: .white,
            quotientToConcentrationDefinitionHighlight: .white,
            quotientToEquilibriumConstantDefinitionHighlight: .white,
            maxWidth: 400,
            maxHeight: 65
        )

        UnscaledAqueousEquationView(
            showTerms: true,
            equations: equations.concentration,
            coefficients: equations.coefficients,
            quotient: ReactionQuotientEquation(equations: equations),
            convergedQuotient: 0.14,
            currentTime: 14,
            kTerm: "K",
            formatElementName: {
                "P\($0.lowercased())"
            },
            generalElementHighlight: .white,
            quotientToCHighlight: .white,
            quotientToEqHighlight: .white
        )
        .border(Color.black)
        .frame(width: NaturalWidth, height: NaturalHeight)
        .previewLayout(.fixed(width: NaturalWidth, height: NaturalHeight))
    }

    private static let equations = BalancedReactionEquation(
        coefficients: BalancedReactionCoefficients(builder: { _ in 2 }),
        equilibriumConstant: 1,
        initialConcentrations: MoleculeValue(builder: { _ in 0.5}),
        startTime: 0,
        equilibriumTime: 10,
        previous: nil
    )
}
