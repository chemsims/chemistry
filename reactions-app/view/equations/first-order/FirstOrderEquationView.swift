//
// Reactions App
//
  

import SwiftUI

struct FirstOrderEquationView: View {

    let emphasiseFilledTerms: Bool
    let c1: CGFloat
    let c2: CGFloat?
    let t: CGFloat?
    let currentTime: CGFloat?
    let concentration: ConcentrationEquation?
    let reactionHasStarted: Bool
    let rateConstantColor: Color
    let halfLifeColor: Color
    let rateColor: Color
    let maxWidth: CGFloat
    let maxHeight: CGFloat
    let reactant: String


    var body: some View {
        ScaledView(
            naturalWidth: EquationSizes.width,
            naturalHeight: EquationSizes.height,
            maxWidth: maxWidth,
            maxHeight: maxHeight
        ) {
            UnscaledFirstOrderReactionEquationView(
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
            ).frame(width: maxWidth, height: maxHeight)
        }
        .accessibilityElement(children: .contain)
    }
}

fileprivate struct UnscaledFirstOrderReactionEquationView: View {

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
            VStack(alignment: .leading, spacing: 0) {
                FirstOrderRateFilled(reactant: reactant)
                FirstOrderRateBlank(
                    emphasise: emphasise,
                    rate: concentration?.rateConstant.str(decimals: 2),
                    lnA0: lnStr(c1),
                    lnAt: c2.map(lnStr),
                    t: t?.str(decimals: 2),
                    reactant: reactant
                )
            }
            .background(
                Color.white.padding(-EquationSizes.padding)
            )
            .colorMultiply(rateConstantColor)

            VStack(alignment: .leading, spacing: 0) {
                FirstOrderHalfLimeFilled()
                FirstOrderHalfLifeBlank(
                    emphasise: emphasise,
                    halfLife: concentration?.halfLife.str(decimals: 2),
                    rate: concentration?.rateConstant.str(decimals: 2)
                )
            }
            .background(
                Color.white.padding(-EquationSizes.padding)
            )
            .colorMultiply(halfLifeColor)

            VStack(alignment: .leading, spacing: 0) {
                BlankRate(order: 1, reactant: reactant)
                FilledRate(
                    order: 1,
                    reactionHasStarted: reactionHasStarted,
                    currentTime: currentTime,
                    concentration: concentration,
                    emphasise: emphasise,
                    reactant: reactant
                )
            }
            .background(
                Color.white.padding(-EquationSizes.padding)
            )
            .colorMultiply(rateColor)
        }
        .font(.system(size: EquationSettings.fontSize))
        .minimumScaleFactor(1)
        .lineLimit(1)
    }

    private func lnStr(_ c: CGFloat) -> String {
        log(c.rounded(decimals: 2)).str(decimals: 2)
    }
}

fileprivate struct FirstOrderRateFilled: View {

    let reactant: String

    var body: some View {
        HStack(spacing: 12) {
            Text("k")
                .frame(width: EquationSettings.boxWidth)
            FixedText("=")
            VStack(spacing: 3) {
                HStack(spacing: 5) {
                    lnA {
                        BracketSubscript(mainValue: reactant, subscriptValue: "0")
                    }.frame(width: 89)
                    FixedText("-")
                    lnA {
                        BracketSubscript(mainValue: reactant, subscriptValue: "t")
                    }.frame(width: 89)
                }
                Rectangle()
                    .frame(width: 200, height: 2)
                Text("t")
                    .fixedSize()

            }
        }
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text("K = natural log of A0 minus natural log of A at time T, divide by T"))
    }

    private func lnA<Content: View>(aTerm: () -> Content) -> some View {
        HStack(spacing: 0) {
            Text("ln")
                .fixedSize()
            aTerm()
        }
    }
}

fileprivate struct FirstOrderRateBlank: View {

    let emphasise: Bool
    let rate: String?
    let lnA0: String?
    let lnAt: String?
    let t: String?
    let reactant: String

    var body: some View {
        HStack(spacing: 12) {
            Placeholder(value: rate, emphasise: emphasise)
                .accessibility(label: Text("k"))
                .accessibility(sortPriority: 10)

            FixedText("=")
                .accessibility(sortPriority: 9)

            VStack(spacing: 1) {
                HStack(spacing: 1) {
                    FixedText("(")
                        .accessibility(hidden: true)
                    Placeholder(value: lnA0, emphasise: lnAt == nil)
                        .accessibility(label: Text("natural log of \(reactant)0"))
                        .accessibility(sortPriority: 8)
                    FixedText(")")
                        .accessibility(hidden: true)
                    FixedText("-")
                        .accessibility(sortPriority: 7)
                        .accessibility(label: Text("minus"))
                    FixedText("(")
                        .accessibility(hidden: true)
                    Placeholder(value: lnAt, emphasise: emphasise)
                        .accessibility(sortPriority: 6)
                        .accessibility(label: Text("natural log of \(reactant) at T"))
                    FixedText(")")
                        .accessibility(hidden: true)
                }
                Rectangle()
                    .frame(width: 200, height: 2)
                    .accessibility(sortPriority: 5)
                    .accessibility(label: Text("divide by"))

                Placeholder(value: t, emphasise: emphasise)
                    .accessibility(sortPriority: 4)
                    .accessibility(label: Text("'T'"))
            }
        }
        .accessibilityElement(children: .contain)
    }
}

fileprivate struct FirstOrderHalfLimeFilled: View {
    var body: some View {
        HStack(spacing: 12) {
            HalfLife()
                .frame(width: EquationSettings.boxWidth)
            FixedText("=")
            HStack(spacing: 12) {
                FixedText("ln(2)")
                    .frame(width: 63)
                FixedText("/")
                Text("k")
                    .frame(width: EquationSettings.boxWidth)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text("'T' 1/2 equals natural log of 2, divide by k"))
    }
}

fileprivate struct FirstOrderHalfLifeBlank: View {

    let emphasise: Bool
    let halfLife: String?
    let rate: String?

    var body: some View {
        HStack(spacing: 12) {
            Placeholder(value: halfLife, emphasise: emphasise)
                .accessibility(label: Text("'T' 1/2"))
            FixedText("=")
            HStack(spacing: 12) {
                FixedText("0.69")
                    .accessibility(label: Text("natural log of 2"))
                    .accessibility(value: Text("0.69"))
                FixedText("/")
                    .accessibility(label: Text("divide by"))
                Placeholder(value: rate, emphasise: emphasise)
                    .accessibility(label: Text("rate"))
            }
        }
    }
}

fileprivate struct EquationSizes {
    static let width: CGFloat = 350
    static let height: CGFloat = 450

    static let padding: CGFloat = 15
}

struct FirstOrderEquationView2_Preview: PreviewProvider {

    static var previews: some View {
        UnscaledFirstOrderReactionEquationView(
            emphasise: true,
            c1: 1,
            c2: 2,
            t: 1,
            currentTime: nil,
            concentration: FirstOrderConcentration(a0: 1, rateConstant: 0.05),
            reactionHasStarted: false,
            rateConstantColor: .white,
            halfLifeColor: .white,
            rateColor: .white,
            reactant: "C"
        )
        .border(Color.red)
        .previewLayout(.fixed(width: EquationSizes.width, height: EquationSizes.height))
    }
}
