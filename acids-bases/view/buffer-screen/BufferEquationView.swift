//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct BufferEquationView: View {
    var body: some View {
        GeometryReader { geo in
            SizedBufferEquationView()
                .scaledToFit(
                    inWidth: geo.size.width,
                    inHeight: geo.size.height,
                    naturalSize: CGSize(
                        width: NaturalWidth,
                        height: NaturalHeight
                    )
                )
                .frame(size: geo.size)
        }
    }
}

private struct SizedBufferEquationView: View {
    var body: some View {
        VStack(spacing: 10) {
            row0
            row1
            row2
            row3
        }
        .font(.system(size: EquationSizing.fontSize))
        .minimumScaleFactor(0.5)
    }

    private var row0: some View {
        HStack(spacing: 0) {
            KADefinition()
                .frame(width: leftColWidth, alignment: .leading)
            Spacer()
                .frame(width: spacerWidth)
            PKADefinition()
                .frame(width: rightColWidth, alignment: .leading)
        }
    }

    private var row1: some View {
        HStack(spacing: 0) {
            KAFilled(
                showTerms: true,
                kaEquation: ConstantEquation(value: 0.003),
                concentration: SubstanceValue(
                    builder: { _ in
                        ConstantEquation(value: 0.05)
                    }
                ),
                progress: 1
            )
            .frame(width: leftColWidth, alignment: .leading)

            Spacer()
                .frame(width: spacerWidth)

            PKAFilled(
                showTerms: true,
                progress: 1,
                pkaEquation: ConstantEquation(value: 0.01),
                kaEquation: ConstantEquation(value: 0.001)
            )
            .frame(width: rightColWidth, alignment: .leading)
        }
    }

    private var row2: some View {
        HStack(spacing: 0) {
            PHDefinition()
                .frame(width: leftColWidth, alignment: .leading)

            Spacer()
                .frame(width: spacerWidth)

            KWDefinition()
                .frame(width: rightColWidth, alignment: .leading)
        }
    }

    private var row3: some View {
        HStack {
            PHFilled(
                showTerms: true,
                progress: 1,
                pkAEquation: ConstantEquation(value: 0.01),
                phEquation: ConstantEquation(value: 0.01),
                secondaryIonConcentration: ConstantEquation(value: 0.01),
                substanceConcentration: ConstantEquation(value: 0.01)
            )
            .frame(width: leftColWidth, alignment: .leading)

            Spacer()
                .frame(width: spacerWidth)

            KWFilled(
                showTerms: true,
                progress: 1,
                kaEquation: ConstantEquation(value: 0.000323),
                kbEquation: ConstantEquation(value: 0.000123)
            )
                .frame(width: rightColWidth, alignment: .leading)
        }
    }
}

private struct KADefinition: View {
    var body: some View {
        HStack(spacing: hStackSpacing) {
            FixedText("Ka")
                .leftColElement()
            FixedText("=")
            VStack(spacing: 3) {
                HStack(spacing: 1) {
                    numerTerm("H", "+")
                    numerTerm("A", "-")
                }
                Rectangle()
                    .frame(width: 110, height: 2)
                FixedText("[HA]")
            }
        }
    }

    private func numerTerm(_ base: String, _ charge: String) -> some View {
        HStack(spacing: 0) {
            FixedText("[\(base)")
            FixedText(charge)
                .font(.system(size: EquationSizing.subscriptFontSize))
                .offset(y: -10)
            FixedText("]")
        }
    }
}

private struct PKADefinition: View {
    var body: some View {
        HStack(spacing: hStackSpacing) {
            FixedText("pKa")
                .frame(width: EquationSizing.boxWidth)
            FixedText("=")
            FixedText("-log(Ka)")
        }
    }
}

private struct KAFilled: View {
    let showTerms: Bool
    let kaEquation: Equation
    let concentration: SubstanceValue<Equation>
    let progress: CGFloat

    var body: some View {
        HStack(spacing: hStackSpacing) {
            ka
            FixedText("=")
            fraction
        }
    }

    private var ka: some View {
        AnimatingScientificText(
            showTerm: showTerms,
            progress: progress,
            equation: kaEquation
        )
    }

    private var fraction: some View {
        VStack(spacing: 3) {
            HStack(spacing: 3) {
                concentration(\.primaryIon)
                concentration(\.secondaryIon)
            }
            Rectangle()
                .frame(width: 150, height: 2)
            concentration(\.substance)
        }
    }

    private func concentration(
        _ equationPath: KeyPath<SubstanceValue<Equation>, Equation>
    ) -> some View {
        HStack(spacing: 0) {
            FixedText("(")
            AnimatingNumberPlaceholder(
                showTerm: showTerms,
                progress: progress,
                equation: concentration[keyPath: equationPath],
                formatter: { "\($0.str(decimals: 2))"}
            )
            .frame(
                width: EquationSizing.boxWidth,
                height: EquationSizing.boxHeight
            )
            FixedText(")")
        }
    }
}

private struct PKAFilled: View {

    let showTerms: Bool
    let progress: CGFloat
    let pkaEquation: Equation
    let kaEquation: Equation

    var body: some View {
        HStack(spacing: hStackSpacing) {
            pka
            FixedText("=")
            ka
        }
    }

    private var pka: some View {
        AnimatingNumberPlaceholder(
            showTerm: showTerms,
            progress: progress,
            equation: pkaEquation,
            formatter: { $0.str(decimals: 2) }
        )
        .frame(
            width: EquationSizing.boxWidth,
            height: EquationSizing.boxHeight
        )
    }

    private var ka: some View {
        HStack(spacing: 1) {
            FixedText("-log(")
            AnimatingScientificText(
                showTerm: showTerms,
                progress: progress,
                equation: kaEquation
            )
            FixedText(")")
        }

    }
}

private struct AnimatingScientificText: View {

    let showTerm: Bool
    let progress: CGFloat
    let equation: Equation

    var body: some View {
        AnimatingNumberPlaceholder(
            showTerm: showTerm,
            progress: progress,
            equation: equation,
            formatter: TextLineUtil.scientificString
        )
        .frame(
            width: largeBoxWidth,
            height: EquationSizing.boxHeight
        )
    }
}

private struct PHDefinition: View {
    var body: some View {
        HStack(spacing: hStackSpacing) {
            FixedText("pH")
                .leftColElement()
            FixedText("=")
            FixedText("pKa")
                .frame(width: EquationSizing.boxWidth)
            FixedText("+")
            log
        }
    }

    private var log: some View {
        HStack(spacing: 1) {
            FixedText("log")
            FixedText("(")
                .scaleEffect(y: largeParenScale)
            VStack(spacing: 1) {
                FixedText("[A]")
                    .frame(width: EquationSizing.boxWidth)
                Rectangle()
                    .frame(width: 55, height: 2)
                FixedText("[HA]")
                    .frame(width: EquationSizing.boxWidth)
            }
            FixedText(")")
                .scaleEffect(y: largeParenScale)
        }
    }
}

private struct KWDefinition: View {
    var body: some View {
        HStack(spacing: hStackSpacing) {
            FixedText("Kw")
                .frame(width: EquationSizing.boxWidth)
            FixedText("=")
            FixedText("Ka")
            FixedText("x")
            FixedText("Kb")
        }
    }
}

private struct PHFilled: View {

    let showTerms: Bool
    let progress: CGFloat
    let pkAEquation: Equation
    let phEquation: Equation
    let secondaryIonConcentration: Equation
    let substanceConcentration: Equation

    var body: some View {
        HStack(spacing: hStackSpacing) {
            element(phEquation)
                .leftColElement()
            FixedText("=")
            sizedElement(pkAEquation)
            FixedText("+")
            log
        }
    }

    private var log: some View {
        HStack(spacing: 1) {
            FixedText("log")
            FixedText("(")
                .scaleEffect(y: largeParenScale)
            VStack(spacing: 1) {
                sizedElement(secondaryIonConcentration)
                Rectangle()
                    .frame(width: 55, height: 2)
                sizedElement(substanceConcentration)
            }
            FixedText(")")
                .scaleEffect(y: largeParenScale)
        }
    }

    private func sizedElement(_ equation: Equation) -> some View {
        element(equation)
            .frame(width: EquationSizing.boxWidth, height: EquationSizing.boxHeight)
    }

    private func element(_ equation: Equation) -> some View {
        AnimatingNumberPlaceholder(
            showTerm: showTerms,
            progress: progress,
            equation: phEquation,
            formatter: { $0.str(decimals: 2) }
        )
    }
}

private struct KWFilled: View {

    let showTerms: Bool
    let progress: CGFloat
    let kaEquation: Equation
    let kbEquation: Equation

    var body: some View {
        HStack(spacing: hStackSpacing) {
            kw
              .frame(width: EquationSizing.boxWidth)
            FixedText("=")
            term(kaEquation)
            FixedText("x")
            term(kbEquation)
        }
    }

    private var kw: some View {
        HStack(spacing: 0) {
            FixedText("10")
            FixedText("-14")
                .font(.system(size: EquationSizing.subscriptFontSize))
                .offset(y: -10)
        }
    }

    private func term(_ equation: Equation) -> some View {
        AnimatingScientificText(
            showTerm: showTerms,
            progress: progress,
            equation: equation
        )
    }
}

private extension View {
    // Places element in box width frame so that the content is
    // centered within that width, and then place it in the full width
    func leftColElement() -> some View {
        self
            .frame(
                width: EquationSizing.boxWidth,
                height: EquationSizing.boxHeight
            )
            .frame(width: largeBoxWidth, alignment: .trailing)
    }
}

private let hStackSpacing: CGFloat = 5
private let largeBoxWidth: CGFloat = 2 * EquationSizing.boxWidth
private let leftColWidth: CGFloat = 350
private let rightColWidth: CGFloat = 440
private let spacerWidth: CGFloat = 150
private let largeParenScale: CGFloat = 2


private let NaturalWidth: CGFloat = 950
private let NaturalHeight: CGFloat = 400

struct BufferEquationView_Previews: PreviewProvider {
    static var previews: some View {
        SizedBufferEquationView()
            .previewLayout(.sizeThatFits)
            .border(Color.black)
            .frame(width: NaturalWidth, height: NaturalHeight)
            .border(Color.red)
    }
}
