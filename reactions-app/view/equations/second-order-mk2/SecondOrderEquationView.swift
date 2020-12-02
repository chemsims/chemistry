//
// Reactions App
//


import SwiftUI

struct SecondOrderEquationView: View {

    let c1: CGFloat
    let c2: CGFloat?
    let rate: CGFloat?
    let t: CGFloat?
    let halfTime: CGFloat?
    let maxWidth: CGFloat
    let maxHeight: CGFloat

    private let naturalWidth: CGFloat = 327
    private let naturalHeight: CGFloat = 312

    var body: some View {
        ScaledView(
            naturalWidth: naturalWidth,
            naturalHeight: naturalHeight,
            maxWidth: maxWidth,
            maxHeight: maxHeight
        ) {
            UnscaledSecondOrderEquationView(
                c1: c1,
                c2: c2,
                rate: rate,
                t: t,
                halfTime: halfTime
            )
        }.frame(width: maxWidth, height: maxHeight)
    }
}

fileprivate struct UnscaledSecondOrderEquationView: View {

    let c1: CGFloat
    let c2: CGFloat?
    let rate: CGFloat?
    let t: CGFloat?
    let halfTime: CGFloat?

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            SecondOrderRateFilled()
            SecondOrderRateBlank(
                rate: rate?.str(decimals: 2),
                invA0: invStr(c1),
                invAt: c2.map(invStr),
                time: t?.str(decimals: 2)
            )
            SecondOrderHalftimeFilled()
            SecondOrderHalftimeBlank(
                halfTime: halfTime?.str(decimals: 2),
                rate: rate?.str(decimals: 2),
                a0: c1.str(decimals: 2)
            )
        }
        .font(.system(size: RateEquationSizes.fontSize))
        .lineLimit(1)
    }

    private func invStr(_ c: CGFloat) -> String {
        (1 / c.rounded(decimals: 2)).str(decimals: 2)
    }
}

fileprivate struct SecondOrderRateFilled: View {
    var body: some View {
        HStack(spacing: 5) {
            Text("k")
                .frame(width: Settings.boxWidth)
            Equals()

            VStack(spacing: 1) {
                HStack(spacing: 5) {
                    inverse {
                        A_t()
                    }
                    Minus()
                    inverse {
                        A_0()
                    }
                }
                Rectangle()
                    .frame(width: 225, height: 2)
                Text("t")
                    .fixedSize()
            }
        }
    }

    private func inverse<Content: View>(aTerm: () -> Content) -> some View {
        HStack(spacing: 0) {
            Text("(1/")
                .fixedSize()
            aTerm()
            Text(")")
                .fixedSize()
        }
    }
}

fileprivate struct SecondOrderRateBlank: View {

    let rate: String?
    let invA0: String?
    let invAt: String?
    let time: String?

    var body: some View {
        HStack(spacing: 5) {
            Placeholder(value: rate)
                .frame(width: Settings.boxWidth, height: Settings.boxHeight)
                .minimumScaleFactor(0.5)

            Equals()

            VStack(spacing: 1) {
                HStack(spacing: 1) {
                    Placeholder(value: invAt)
                        .frame(width: Settings.boxWidth, height: Settings.boxHeight)
                        .minimumScaleFactor(0.5)

                    Minus()

                    Placeholder(value: invA0)
                        .frame(width: Settings.boxWidth, height: Settings.boxHeight)
                        .minimumScaleFactor(0.5)
                }

                Rectangle()
                    .frame(width: 180, height: 2)

                Placeholder(value: time)
                    .frame(width: Settings.boxWidth, height: Settings.boxHeight)
                    .minimumScaleFactor(0.5)
            }
        }
    }
}

fileprivate struct SecondOrderHalftimeFilled: View {
    var body: some View {
        HStack(spacing: 5) {
            HalfTime()
                .frame(width: Settings.boxWidth)
            Equals()
            Text("1")
                .fixedSize()
            Divide()
            Text("(k")
                .fixedSize()
            A_0()
            Text(")")
                .fixedSize()
        }
    }
}

fileprivate struct SecondOrderHalftimeBlank: View {

    let halfTime: String?
    let rate: String?
    let a0: String?

    var body: some View {
        HStack(spacing: 5) {
            Placeholder(value: halfTime)
                .frame(width: Settings.boxWidth, height: Settings.boxHeight)
                .minimumScaleFactor(0.5)

            Equals()

            Text("1")
                .fixedSize()
            Divide()

            Placeholder(value: rate)
                .frame(width: Settings.boxWidth, height: Settings.boxHeight)
                .minimumScaleFactor(0.5)

            if (a0 != nil) {
                Text("(")
                    .fixedSize()

                Text(a0!)
                    .frame(width: Settings.boxWidth * 0.8)
                    .minimumScaleFactor(0.5)
                Text(")")
                    .fixedSize()
            } else {
                Box()
                    .frame(width: Settings.boxWidth, height: Settings.boxHeight)
            }
        }
    }
}


struct SecondOrderEquationView2_Previews: PreviewProvider {
    static var previews: some View {
        UnscaledSecondOrderEquationView(
            c1: 1.23,
            c2: 0.34,
            rate: 1.45,
            t: 1.4,
            halfTime: 2.34
        )
        .previewLayout(.fixed(width: 600, height: 600))
    }
}
