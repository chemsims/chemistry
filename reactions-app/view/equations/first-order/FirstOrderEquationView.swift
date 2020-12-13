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
                rateColor: rateColor
            ).frame(width: maxWidth, height: maxHeight)
        }
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

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            VStack(alignment: .leading, spacing: 0) {
                FirstOrderRateFilled()
                FirstOrderRateBlank(
                    emphasise: emphasise,
                    rate: concentration?.rateConstant.str(decimals: 2),
                    lnA0: lnStr(c1),
                    lnAt: c2.map(lnStr),
                    t: t?.str(decimals: 2)
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
                BlankRate(order: 1)
                FilledRate(
                    reactionHasStarted: reactionHasStarted,
                    currentTime: currentTime,
                    concentration: concentration,
                    emphasise: emphasise
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

    var body: some View {
        HStack(spacing: 12) {
            Text("k")
                .frame(width: EquationSettings.boxWidth)
            FixedText("=")
            VStack(spacing: 3) {
                HStack(spacing: 5) {
                    lnA {
                        A_0()
                    }.frame(width: 89)
                    FixedText("-")
                    lnA {
                        A_t()
                    }.frame(width: 89)
                }
                Rectangle()
                    .frame(width: 200, height: 2)
                Text("t")
                    .fixedSize()

            }
        }
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

    var body: some View {
        HStack(spacing: 12) {
            Placeholder(value: rate, emphasise: emphasise)
            FixedText("=")
            VStack(spacing: 1) {
                HStack(spacing: 1) {
                    FixedText("(")
                    Placeholder(value: lnA0, emphasise: lnAt == nil)
                    FixedText(")")
                    FixedText("-")
                    FixedText("(")
                    Placeholder(value: lnAt, emphasise: emphasise)
                    FixedText(")")
                }
                Rectangle()
                    .frame(width: 200, height: 2)
                Placeholder(value: t, emphasise: emphasise)
            }
        }
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
    }
}

fileprivate struct FirstOrderHalfLifeBlank: View {

    let emphasise: Bool
    let halfLife: String?
    let rate: String?

    var body: some View {
        HStack(spacing: 12) {
            Placeholder(value: halfLife, emphasise: emphasise)
            FixedText("=")
            HStack(spacing: 12) {
                FixedText("0.69")
                FixedText("/")
                Placeholder(value: rate, emphasise: emphasise)
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
            concentration: FirstOrderConcentration(c1: 1, c2: 0.1, time: 10),
            reactionHasStarted: false,
            rateConstantColor: .white,
            halfLifeColor: .white,
            rateColor: .white
        )
        .border(Color.red)
        .previewLayout(.fixed(width: EquationSizes.width, height: EquationSizes.height))
    }
}
