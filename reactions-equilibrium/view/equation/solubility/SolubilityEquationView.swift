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
    }
}

private struct SizedSolubilityEquationView: View {

    @ObservedObject var model: SolubilityViewModel

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 5) {
                QuotientConcentrationDefinition(
                    isStruckOut: model.equationState == .crossOutOriginalQuotientDenominator,
                    showDenom: model.equationState.doShowOriginalQuotient
                )
                .frame(height: 90)

                QuotientConcentrationBlank(
                    quotient: model.components.quotient,
                    concentration: model.components.equation.concentration,
                    currentTime: model.currentTime,
                    showValues: model.equationState == .showCorrectQuotientFilledIn
                )
                .opacity(model.equationState.doShowCorrectQuotient ? 1 : 0)
            }
            Spacer()
                .frame(width: 45)
            VStack(alignment: .leading, spacing: 5) {
                QuotientKspDefinition()
                    .frame(height: 90)
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

    var body: some View {
        ZStack {
            content

            CrossOutLine(
                start: CGPoint(x: 115, y: 65),
                end: CGPoint(x: 215, y: 40),
                progress: isStruckOut ? 1: 0
            )
            .stroke(lineWidth: 3)
            .foregroundColor(.red)
            .frame(width: 230, height: 50)

//            if isStruckOut {
//                Rectangle()
//                    .frame(width: 90, height: 4)
//                    .foregroundColor(.red)
//                    .rotationEffect(.degrees(-14))
//                    .position(x: 167, y: 70)
//                    .opacity(isStruckOut ? 1 : 0)
//                    .transition(.scale)
//                    .animation(.easeOut(duration: 0.5))
//            }
        }
        .frame(width: 230)
    }

    private var content: some View {
        HStack(spacing: 2) {
            FixedText("Q")
                .frame(width: EquationSizing.boxWidth)
            Equals()
            VStack(spacing: 2) {
                HStack(spacing: 2) {
                    term("A", "+")
                    term("B", "-")
                }
                if showDenom {
                    Rectangle()
                        .frame(width: 110, height: 2)
                    HStack(spacing: 2) {
                        FixedText("[AB]")
                    }
                }

            }
        }
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
    var body: some View {
        HStack(spacing: 2) {
            FixedText("Q")
                .frame(width: EquationSizing.boxWidth)
            Equals()
            FixedText("Ksp")
                .frame(width: EquationSizing.boxWidth)
        }
    }
}

private struct QuotientConcentrationBlank: View {

    let quotient: Equation
    let concentration: SoluteValues<Equation>
    let currentTime: CGFloat
    let showValues: Bool

    var body: some View {
        HStack(spacing: 2) {
            term(quotient, parens: false)
            Equals()
            term(concentration.productA)
            term(concentration.productB)
        }
    }

    private func term(_ equation: Equation, parens: Bool = true) -> some View {
        AnimatingNumberOrPlaceholder(
            showTerm: showValues,
            currentTime: currentTime,
            equation: equation,
            formatter: {
                let value = $0.str(decimals: 2)
                return parens ? "(\(value))" : value
            }
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
            Equals()
            FixedText(ksp.str(decimals: 2))
        }
    }

    private var quotientView: some View {
        AnimatingNumberOrPlaceholder(
            showTerm: showValues,
            currentTime: currentTime,
            equation: quotient,
            formatter: { $0.str(decimals: 2) }
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
        SizedSolubilityEquationView(model: SolubilityViewModel())
            .border(Color.red)
            .frame(width: NaturalWidth, height: NaturalHeight)
            .border(Color.black)
            .previewLayout(.iPhoneSELandscape)
    }
}
