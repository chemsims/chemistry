//
// Reactions App
//
  

import SwiftUI

struct FirstOrderEquationView: View {

    let c1: CGFloat
    let c2: CGFloat?
    let t: CGFloat?
    let rate: CGFloat?
    let halfTime: CGFloat?
    let maxWidth: CGFloat
    let maxHeight: CGFloat

    private let naturalWidth: CGFloat = 294
    private let naturalHeight: CGFloat = 313

    var body: some View {
        ScaledView(
            naturalWidth: naturalWidth,
            naturalHeight: naturalHeight,
            maxWidth: maxWidth,
            maxHeight: maxHeight
        ) {
            UnscaledFirstOrderReactionEquationView(
                c1: c1,
                c2: c2,
                t: t,
                rate: rate,
                halfTime: halfTime
            ).frame(width: maxWidth, height: maxHeight)
        }
    }
}

fileprivate struct UnscaledFirstOrderReactionEquationView: View {

    let c1: CGFloat
    let c2: CGFloat?
    let t: CGFloat?
    let rate: CGFloat?
    let halfTime: CGFloat?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            FirstOrderRateFilled()
            FirstOrderRateBlank(
                rate: rate?.str(decimals: 2),
                a0: c1.str(decimals: 2),
                at: c2?.str(decimals: 2),
                t: t?.str(decimals: 2)
            )
            FirstOrderHalftimeFilled()
            FirstOrderHalftimeBlank(
                halftime: halfTime?.str(decimals: 2),
                rate: rate?.str(decimals: 2)
            )
        }
        .font(.system(size: RateEquationSizes.fontSize))
        .lineLimit(1)
    }
}

fileprivate struct FirstOrderRateFilled: View {

    var body: some View {
        HStack(spacing: 12) {
            Text("k")
                .frame(width: Settings.boxWidth)
            Equals()
            VStack(spacing: 3) {
                HStack(spacing: 5) {
                    lnA {
                        A_0()
                    }
                    Minus()
                    lnA {
                        A_t()
                    }
                }
                Rectangle()
                    .frame(width: 180, height: 2)
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

    let rate: String?
    let a0: String?
    let at: String?
    let t: String?

    var body: some View {
        HStack(spacing: 12) {
            Placeholder(value: rate)
                .frame(width: Settings.boxWidth, height: Settings.boxHeight)
                .minimumScaleFactor(0.5)
            Equals()
            VStack(spacing: 1) {
                HStack(spacing: 1) {
                    Placeholder(value: a0)
                        .frame(width: Settings.boxWidth, height: Settings.boxHeight)
                        .minimumScaleFactor(0.5)
                    Minus()
                    Placeholder(value: at)
                        .frame(width: Settings.boxWidth, height: Settings.boxHeight)
                        .minimumScaleFactor(0.5)
                }
                Rectangle()
                    .frame(width: 150, height: 2)
                Placeholder(value: t)
                    .frame(width: Settings.boxWidth, height: Settings.boxHeight)
                    .minimumScaleFactor(0.5)
            }
        }
    }
}

fileprivate struct FirstOrderHalftimeFilled: View {
    var body: some View {
        HStack(spacing: 12) {
            HalfTime()
                .frame(width: Settings.boxWidth)
            Equals()
            HStack(spacing: 12) {
                Text("ln(2)")
                    .fixedSize()
                Divide()
                Text("k")
                    .frame(width: Settings.boxWidth)
            }
        }
    }
}

fileprivate struct FirstOrderHalftimeBlank: View {

    let halftime: String?
    let rate: String?

    var body: some View {
        HStack(spacing: 12) {
            Placeholder(value: halftime)
                .frame(width: Settings.boxWidth, height: Settings.boxHeight)
                .minimumScaleFactor(0.5)
            Equals()
            HStack(spacing: 12) {
                Text("0.69")
                    .fixedSize()
                Divide()
                Placeholder(value: rate)
                    .frame(width: Settings.boxWidth, height: Settings.boxHeight)
                    .minimumScaleFactor(0.5)
            }
        }
    }
}

struct FirstOrderEquationView2_Preview: PreviewProvider {

    static let w: CGFloat = 250
    static let h: CGFloat = 100

    static var previews: some View {
        UnscaledFirstOrderReactionEquationView(
            c1: 1,
            c2: 2,
            t: 1,
            rate: 1,
            halfTime: 1
        )
        .previewLayout(.fixed(width: 600, height: 600))
    }
}
