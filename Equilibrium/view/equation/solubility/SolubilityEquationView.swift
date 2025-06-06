//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct SolubilityEquationView: View {

    let model: SolubilityViewModel

    var body: some View {
        GeometryReader { geo in
            ScaledView(
                naturalWidth: NaturalWidth,
                naturalHeight: NaturalHeight,
                maxWidth: geo.size.width,
                maxHeight: geo.size.height
            ) {
                SizedSolubilityEquationView(model: model)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .accessibilityElement(children: .contain)
    }
}

private struct SizedSolubilityEquationView: View {

    @ObservedObject var model: SolubilityViewModel

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 5) {
                QuotientConcentrationDefinition(
                    isStruckOut: model.equationState.doCrossOutDenom,
                    showDenom: model.equationState.doShowOriginalQuotient,
                    products: model.selectedReaction.products
                )
                .frame(height: 90)
                .background(Color.white.padding(-5))
                .colorMultiply(
                    model.highlights.colorMultiply(
                        for: .quotientToConcentrationDefinition
                    )
                )

                QuotientConcentrationBlank(
                    quotient: model.components.quotient,
                    concentration: model.components.equation.concentration,
                    currentTime: model.currentTime,
                    showValues: model.equationState == .showCorrectQuotientFilledIn,
                    products: model.selectedReaction.products
                )
                .opacity(model.equationState.doShowCorrectQuotient ? 1 : 0)
            }
            Spacer()
                .frame(width: 45)
            VStack(alignment: .leading, spacing: 5) {
                QuotientKspDefinition(
                    quotient: model.components.quotient,
                    currentTime: model.currentTime,
                    convergedQuotient: model.components.equilibriumConstant
                )
                .frame(height: 90)
                .background(Color.white.padding(-5))
                .colorMultiply(
                    model.highlights.colorMultiply(
                        for: .quotientToKspDefinition
                    )
                )


                QuotientKspBlank(
                    quotient: model.components.quotient,
                    ksp: model.components.equilibriumConstant,
                    currentTime: model.currentTime,
                    showValues: model.equationState == .showCorrectQuotientFilledIn
                )
                .opacity(model.equationState.doShowCorrectQuotient ? 1 : 0)
            }
        }
        .font(.system(size: EquationSizing.fontSize))
    }
}

private struct QuotientConcentrationDefinition: View {

    let isStruckOut: Bool
    let showDenom: Bool
    let products: SolubleProductPair

    var body: some View {
        ZStack {
            content

            if showDenom {
                CrossOutLine(
                    start: CGPoint(x: 115, y: 65),
                    end: CGPoint(x: 215, y: 40),
                    progress: isStruckOut ? 1: 0
                )
                .stroke(lineWidth: 3)
                .foregroundColor(.red)
                .frame(width: 230, height: 50)
            }
        }
        .frame(width: 250)
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text(label))
    }

    private var label: String {
        let base = """
        Q equals concentration of \(products.first) times concentration of \(products.second)
        """

        var denom: String {
            if isStruckOut && showDenom {
                return ". Denominator is concentration of \(products.salt), which has been crossed out"
            } else if !isStruckOut {
                return ", divide by concentration of \(products.salt)"
            }
            return ""
        }

        return "\(base)\(denom)"
    }

    private var content: some View {
        HStack(spacing: 2) {
            FixedText("Q")
                .frame(width: EquationSizing.boxWidth)
            Equals()
            VStack(spacing: 2) {
                HStack(spacing: 2) {
                    term(products.first, "+")
                    term(products.second, "-")
                }
                if showDenom {
                    Rectangle()
                        .frame(width: 110, height: 2)
                    HStack(spacing: 2) {
                        FixedText("[\(products.salt)]")
                            .frame(width: 65)
                    }
                }
            }
            .frame(width: 130)
            Spacer()
        }
        .animation(nil)
    }

    private func term(_ name: String, _ power: String) -> some View {
        HStack(spacing: 2) {
            FixedText("[")
            FixedText(name)
            Text(power)
                .baselineOffset(18)
                .fixedSize()
                .font(.system(size: EquationSizing.subscriptFontSize))
            FixedText("]")
        }
    }
}

private struct CrossOutLine: Shape {
    let start: CGPoint
    let end: CGPoint
    var progress: CGFloat
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        func getPart(_ startPart: CGFloat, _ endPart: CGFloat) -> CGFloat {
            let dPart = endPart - startPart
            return startPart + (progress * dPart)
        }
        var path = Path()
        path.move(to: start)
        path.addLine(
            to: CGPoint(
                x: getPart(start.x, end.x),
                y: getPart(start.y, end.y)
            )
        )
        return path
    }
}

private struct QuotientKspDefinition: View {

    let quotient: Equation
    let currentTime: CGFloat
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
            FixedText("Ksp")
                .frame(width: EquationSizing.boxWidth)
        }
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text(label))
        .accessibility(addTraits: .updatesFrequently)
    }

    private var label: String {
        let symbol = QuotientEqualitySign.formatEquals(
            quotient: quotient.getValue(at: currentTime),
            convergedQuotient: convergedQuotient
        )
        return "Q \(symbol) Ksp"
    }
}

private struct QuotientConcentrationBlank: View {

    let quotient: Equation
    let concentration: SoluteValues<Equation>
    let currentTime: CGFloat
    let showValues: Bool
    let products: SolubleProductPair

    var body: some View {
        HStack(spacing: 2) {
            term(quotient, parens: false)
                .accessibility(label: Text("Q"))
            Equals()
            term(concentration.productA)
                .accessibility(label: Text("concentration of \(products.first)"))
            term(concentration.productB)
                .accessibility(label: Text("concentration of \(products.second)"))
        }
        .accessibilityElement(children: .contain)
    }

    private func term(_ equation: Equation, parens: Bool = true) -> some View {
        AnimatingNumberPlaceholder(
            showTerm: showValues,
            progress: currentTime,
            equation: equation,
            formatter: {
                let value = $0.str(decimals: 2)
                return parens ? "(\(value))" : value
            }
        )
        .frame(
            width: EquationSizing.boxWidth,
            height: EquationSizing.boxHeight
        )
    }
}

private struct QuotientKspBlank: View {
    let quotient: Equation
    let ksp: CGFloat
    let currentTime: CGFloat
    let showValues: Bool

    var body: some View {
        HStack(spacing: 2) {
            quotientView
                .accessibility(label: Text("Q"))
            QuotientEqualitySign(
                currentTime: currentTime,
                quotient: quotient,
                convergedQuotient: ksp
            )
            .frame(width: 35)
            FixedText(ksp.str(decimals: 2))
                .foregroundColor(.orangeAccent)
                .accessibility(label: Text("Ksp"))
                .accessibility(value: Text("\(ksp.str(decimals: 2))"))
        }
        .accessibilityElement(children: .contain)
    }

    private var quotientView: some View {
        AnimatingNumberPlaceholder(
            showTerm: showValues,
            progress: currentTime,
            equation: quotient,
            formatter: { $0.str(decimals: 2) }
        )
        .frame(
            width: EquationSizing.boxWidth,
            height: EquationSizing.boxHeight
        )
    }
}

private struct Equals: View {
    var body: some View {
        FixedText("=")
            .frame(width: 35)
    }
}

private let NaturalHeight: CGFloat = 146
private let NaturalWidth: CGFloat = 475

struct SolubilityEquationView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Styling.inactiveScreenElement)

            SizedSolubilityEquationView(model: SolubilityViewModel(
                persistence: InMemorySolubilityPersistence()
            ))
                .border(Color.red)
                .frame(width: NaturalWidth, height: NaturalHeight)
                .border(Color.black)
        }
        .previewLayout(.iPhoneSELandscape)
    }
}
