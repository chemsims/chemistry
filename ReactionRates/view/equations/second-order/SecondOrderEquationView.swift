//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct SecondOrderEquationView: View {

    let emphasiseFilledTerms: Bool
    let c1: CGFloat
    let c2: CGFloat?
    let t: CGFloat?
    let currentTime: CGFloat?
    let concentration: ConcentrationEquation?
    let reactionHasStarted: Bool
    let maxWidth: CGFloat
    let maxHeight: CGFloat
    let rateConstantColor: Color
    let halfLifeColor: Color
    let rateColor: Color
    let reactant: String

    var body: some View {
        ScaledView(
            naturalWidth: EquationSize.width,
            naturalHeight: EquationSize.height,
            maxWidth: maxWidth,
            maxHeight: maxHeight
        ) {
            UnscaledSecondOrderEquationView(
                emphasise: emphasiseFilledTerms,
                c1: c1,
                c2: c2,
                t: t,
                currentTime: currentTime,
                concentration: concentration,
                reactionHasStarted: reactionHasStarted,
                rateConstantColor: rateConstantColor,
                halfLifeColor: halfLifeColor,
                rateColor: rateColor,
                reactant: reactant
            )
        }
        .frame(width: maxWidth, height: maxHeight)
        .accessibilityElement(children: .contain)
    }
}

private struct UnscaledSecondOrderEquationView: View {

    let emphasise: Bool
    let c1: CGFloat
    let c2: CGFloat?
    let t: CGFloat?
    let currentTime: CGFloat?
    let concentration: ConcentrationEquation?
    let reactionHasStarted: Bool
    let rateConstantColor: Color
    let halfLifeColor: Color
    let rateColor: Color
    let reactant: String

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            VStack(spacing: 0) {
                SecondOrderRateFilled(reactant: reactant)
                    .accessibility(addTraits: .isHeader)
                SecondOrderRateBlank(
                    reactant: reactant,
                    emphasise: emphasise,
                    rateConstant: concentration?.rateConstant.str(decimals: 2),
                    invA0: invStr(c1),
                    invAt: c2.map(invStr),
                    time: t?.str(decimals: 2)
                )
            }
            .background(Color.white.padding(-EquationSize.padding))
            .colorMultiply(rateConstantColor)

            VStack(alignment: .leading, spacing: 0) {
                SecondOrderHalfLifeFilled(reactant: reactant)
                SecondOrderHalfLifeBlank(
                    reactant: reactant,
                    emphasise: emphasise,
                    halfLife: concentration?.halfLife.str(decimals: 2),
                    rateConstant: concentration?.rateConstant.str(decimals: 2),
                    a0: c1.str(decimals: 2)
                )
            }
            .background(Color.white.padding(-EquationSize.padding))
            .colorMultiply(halfLifeColor)

            VStack(alignment: .leading, spacing: 0) {
                BlankRate(order: 2, reactant: reactant)
                FilledRate(
                    order: 2,
                    reactionHasStarted: reactionHasStarted,
                    currentTime: currentTime,
                    concentration: concentration,
                    emphasise: emphasise,
                    reactant: reactant
                )
            }
            .background(Color.white.padding(-EquationSize.padding))
            .colorMultiply(rateColor)
        }
        .font(.system(size: EquationSettings.fontSize))
        .lineLimit(1)
        .minimumScaleFactor(1)
    }

    private func invStr(_ c: CGFloat) -> String {
        (1 / c.rounded(decimals: 2)).str(decimals: 2)
    }
}

private struct SecondOrderRateFilled: View {

    let reactant: String

    var body: some View {
        HStack(spacing: 5) {
            FixedText("k")
                .frame(width: EquationSettings.boxWidth)
            FixedText("=")

            VStack(spacing: 1) {
                HStack(spacing: 5) {
                    inverse {
                        BracketSubscript(mainValue: reactant, subscriptValue: "t")
                    }.frame(width: 100)
                    FixedText("-")
                    inverse {
                        BracketSubscript(mainValue: reactant, subscriptValue: "0")
                    }.frame(width: 100)
                }
                Rectangle()
                    .frame(width: 225, height: 2)
                FixedText("t")
                    .fixedSize()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibility(
            label: Text(
                "k equals, inverse \(reactant) T minus inverse \(reactant)0, divide by T"
            )
        )
    }

    private func inverse<Content: View>(aTerm: () -> Content) -> some View {
        HStack(spacing: 0) {
            FixedText("(1/")
            aTerm()
            FixedText(")")
        }
    }
}

private struct SecondOrderRateBlank: View {

    let reactant: String
    let emphasise: Bool
    let rateConstant: String?
    let invA0: String?
    let invAt: String?
    let time: String?

    var body: some View {
        HStack(spacing: 5) {
            Placeholder(value: rateConstant, emphasise: emphasise)
                .accessibility(sortPriority: 10)
                .accessibility(label: Text("k"))

            FixedText("=")
                .accessibility(sortPriority: 9)

            VStack(spacing: 1) {
                HStack(spacing: 1) {
                    Placeholder(value: invAt, emphasise: emphasise)
                        .frame(width: 100)
                        .accessibility(sortPriority: 8)
                        .accessibility(label: Text("inverse \(reactant) T"))

                    FixedText("-")
                        .accessibility(sortPriority: 7)
                        .accessibility(label: Text("minus"))

                    Placeholder(value: invA0, emphasise: invAt == nil)
                        .frame(width: 100)
                        .accessibility(sortPriority: 6)
                        .accessibility(label: Text("inverse \(reactant)0"))
                }

                Rectangle()
                    .frame(width: 225, height: 2)
                    .accessibility(sortPriority: 5)
                    .accessibility(label: Text("divide by"))

                Placeholder(value: time, emphasise: emphasise)
                    .accessibility(sortPriority: 4)
                    .accessibility(label: Text("'T'"))
            }
        }
        .accessibilityElement(children: .contain)
    }
}

private struct SecondOrderHalfLifeFilled: View {

    let reactant: String

    var body: some View {
        HStack(spacing: 5) {
            HalfLife()
                .frame(width: EquationSettings.boxWidth)
            FixedText("=")
            FixedText("1")
            FixedText("/")
            FixedText("(k")
            BracketSubscript(mainValue: reactant, subscriptValue: "0")
            FixedText(")")
        }
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text("'T' 1/2 equals 1, divide by k times \(reactant)0"))
    }
}

private struct SecondOrderHalfLifeBlank: View {

    let reactant: String
    let emphasise: Bool
    let halfLife: String?
    let rateConstant: String?
    let a0: String

    var body: some View {
        HStack(spacing: 5) {
            Placeholder(value: halfLife, emphasise: emphasise)
                .accessibility(label: Text("'T' 1/2"))

            FixedText("=")

            FixedText("1")

            HStack(spacing: 1) {
                FixedText("/")
                    .accessibility(label: Text("divide by"))

                Placeholder(value: rateConstant, emphasise: emphasise)
                    .accessibility(label: Text("k"))
                FixedText("(")
                    .accessibility(label: Text(Labels.openParen))
                FixedText(a0)
                    .frame(width: EquationSettings.boxWidth * 0.8)
                    .minimumScaleFactor(0.5)
                    .foregroundColor(rateConstant == nil ? .orangeAccent : .black)
                    .accessibility(label: Text("\(reactant)0"))
                    .accessibility(value: Text(a0))
                FixedText(")")
                    .accessibility(label: Text(Labels.closedParen))
            }
        }
    }
}

private struct EquationSize {
    static let width: CGFloat = 360
    static let height: CGFloat = 446
    static let padding: CGFloat = 15
}

struct SecondOrderEquationView2_Previews: PreviewProvider {
    static var previews: some View {
        UnscaledSecondOrderEquationView(
            emphasise: true,
            c1: 1.23,
            c2: 0.34,
            t: 1.4,
            currentTime: 5,
            concentration: SecondOrderConcentration(a0: 0.5, rateConstant: 0.1),
            reactionHasStarted: false,
            rateConstantColor: .white,
            halfLifeColor: .white,
            rateColor: .white,
            reactant: "A"
        )
        .border(Color.red)
        .previewLayout(.fixed(width: EquationSize.width, height: EquationSize.height))
    }
}
