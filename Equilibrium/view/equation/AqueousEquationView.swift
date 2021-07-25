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

    let propertyAccessibilityLabel: String

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
                quotientToEqHighlight: quotientToEquilibriumConstantDefinitionHighlight,
                propertyAccessibilityLabel: propertyAccessibilityLabel
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

    let propertyAccessibilityLabel: String

    var body: some View {
        VStack(spacing: 1) {
            HStack(spacing: 40) {
                QuotientDefinitionView(
                    coefficients: coefficients,
                    formatName: formatElementName,
                    propertyAccessibilityLabel: propertyAccessibilityLabel
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
                    currentTime: currentTime,
                    propertyAccessibilityLabel: propertyAccessibilityLabel
                )
                .colorMultiply(generalElementHighlight)
                Spacer()
                FilledQuotientKView(
                    showTerms: showTerms,
                    kTerm: kTerm,
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
        .accessibilityElement(children: .contain)
    }
}

private struct QuotientDefinitionView: View {

    let coefficients: BalancedReactionCoefficients
    let formatName: (String) -> String
    let propertyAccessibilityLabel: String

    var body: some View {
        HStack(spacing: 4) {
            FixedText("Q")
                .frame(width: EquationSizing.boxWidth)
            FixedText("=")
                .frame(width: 22)
            fraction
                .frame(width: 150)
        }
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text(label))
    }

    private var label: String {
        func moleculeLabel(_ molecule: AqueousMolecule) -> String {
            let coeff = coefficients.value(for: molecule)
            let power = coeff == 1 ? "" : " to the power of \(coeff)"
            return "\(propertyAccessibilityLabel) of \(molecule.rawValue)\(power)"
        }

        return """
        Q equals \(moleculeLabel(.C)) times \(moleculeLabel(.D)), divide by
        \(moleculeLabel(.A)) times \(moleculeLabel(.B))
        """
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
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text(label))
        .accessibility(addTraits: .updatesFrequently)
    }

    private var label: String {
        let quotient = self.quotient.getY(at: currentTime)
        let symbol = QuotientEqualitySign.formatEquals(quotient: quotient, convergedQuotient: convergedQuotient)
        return "Q \(symbol) \(kTerm)"
    }
}

private struct FilledQuotientDefinitionView: View {

    let showTerms: Bool
    let equations: MoleculeValue<Equation>
    let coefficients: MoleculeValue<Int>
    let quotient: Equation
    let currentTime: CGFloat
    let propertyAccessibilityLabel: String

    var body: some View {
        HStack(spacing: 4) {
            AnimatingNumberPlaceholder(
                showTerm: showTerms,
                progress: currentTime,
                equation: quotient,
                formatter: formatQuotient
            )
            .frame(
                width: EquationSizing.boxWidth,
                height: EquationSizing.boxHeight
            )
            .accessibility(label: Text("Q"))
            .accessibility(sortPriority: 10)
            FixedText("=")
                .accessibility(sortPriority: 9)
            fraction
                .accessibility(sortPriority: 8)
        }
        .minimumScaleFactor(0.5)
        .accessibilityElement(children: .contain)
    }

    private var fraction: some View {
        VStack(spacing: 4) {
            HStack(spacing: 3) {
                concentration(.C)
                concentration(.D)
            }
            Rectangle()
                .frame(width:  170, height: 1)
                .accessibility(label: Text("Divide by"))

            HStack(spacing: 3) {
                concentration(.A)
                concentration(.B)
            }
        }
    }

    private func concentration(
        _ molecule: AqueousMolecule
    ) -> some View {
        let coeff = coefficients.value(for: molecule)
        let label = coeff == 1 ? "" : "To the power of \(coeff)"
        return HStack(spacing: 2) {
            AnimatingNumberPlaceholder(
                showTerm: showTerms,
                progress: currentTime,
                equation: equations.value(for: molecule),
                formatter: { "(\($0.str(decimals: 2)))" }
            )
            .frame(
                width: EquationSizing.boxWidth,
                height: EquationSizing.boxHeight
            )
            .accessibility(label: Text("\(propertyAccessibilityLabel) of \(molecule.rawValue)"))

            FixedText("\(coeff)")
                .offset(y: -10)
                .font(.system(size: EquationSizing.subscriptFontSize))
                .opacity(coeff == 1 ? 0 : 1)
                .animation(nil)
                .frame(width: 15)
                .accessibility(label: Text(label))
        }
    }
}

private struct FilledQuotientKView: View {

    let showTerms: Bool
    let kTerm: String
    let quotient: Equation
    let convergedQuotient: CGFloat
    let currentTime: CGFloat

    var body: some View {
        HStack(spacing: 2) {
            AnimatingNumberPlaceholder(
                showTerm: showTerms,
                progress: currentTime,
                equation: quotient,
                formatter: formatQuotient
            )
            .frame(
                width: EquationSizing.boxWidth,
                height: EquationSizing.boxHeight
            )
            .accessibility(label: Text("Q"))

            QuotientEqualitySign(
                currentTime: currentTime,
                quotient: quotient,
                convergedQuotient: convergedQuotient
            )

            AnimatingNumberPlaceholder(
                showTerm: showTerms,
                progress: currentTime,
                equation: ConstantEquation(value: convergedQuotient),
                formatter: { $0.str(decimals: 2) }
            )
            .frame(
                width: EquationSizing.boxWidth,
                height: EquationSizing.boxHeight
            )
            .accessibility(label: Text("\(kTerm)"))
        }
        .accessibilityElement(children: .contain)
    }
}

struct QuotientEqualitySign: View {

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
        .accessibility(value: Text("")) // Remove the value, since the symbol is already read out in the label
    }

    private func formatEquals(at quotient: CGFloat) -> String {
        Self.formatEquals(quotient: quotient, convergedQuotient: convergedQuotient)
    }

    static func formatEquals(
        quotient: CGFloat,
        convergedQuotient: CGFloat
    ) -> String {
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
            propertyAccessibilityLabel: "",
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
            quotientToEqHighlight: .white,
            propertyAccessibilityLabel: ""
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
