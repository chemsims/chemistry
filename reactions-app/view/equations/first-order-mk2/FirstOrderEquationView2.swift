//
// Reactions App
//
  

import SwiftUI

struct FirstOrderEquationView2: View {

    let c1: CGFloat
    let c2: CGFloat?
    let t: CGFloat?
    let rate: CGFloat?
    let halfTime: CGFloat?
    let maxWidth: CGFloat
    let maxHeight: CGFloat

    private let naturalWidth: CGFloat = 296
    private let naturalHeight: CGFloat = 310

    var body: some View {
        ScaledView(
            naturalWidth: naturalWidth,
            naturalHeight: naturalHeight,
            maxWidth: maxWidth,
            maxHeight: maxHeight
        ) {
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
            .minimumScaleFactor(0.5)
        }.frame(width: maxWidth, height: maxHeight)
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
                    .frame(width: 20)

            }
        }
    }

    private func lnA<Content: View>(aTerm: () -> Content) -> some View {
        HStack(spacing: 0) {
            Text("ln")
                .frame(width: 24)
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
            Equals()
            VStack(spacing: 1) {
                HStack(spacing: 1) {
                    Placeholder(value: a0)
                        .frame(width: Settings.boxWidth, height: Settings.boxHeight)
                    Minus()
                    Placeholder(value: at)
                        .frame(width: Settings.boxWidth, height: Settings.boxHeight)
                }
                Rectangle()
                    .frame(width: 150, height: 2)
                Placeholder(value: t)
                    .frame(width: Settings.boxWidth, height: Settings.boxHeight)
            }
        }
    }
}

fileprivate struct FirstOrderHalftimeFilled: View {
    var body: some View {
        HStack(spacing: 1) {
            HalfTime()
                .frame(width: Settings.boxWidth)
            Equals()
            Text("ln(2)")
                .frame(width: 80)
            Divide()
            Text("k")
                .frame(width: Settings.boxWidth)
        }
    }
}

fileprivate struct FirstOrderHalftimeBlank: View {

    let halftime: String?
    let rate: String?

    var body: some View {
        HStack(spacing: 1) {
            Placeholder(value: halftime)
                .frame(width: Settings.boxWidth, height: Settings.boxHeight)
            Equals()
            Text("0.69")
                .frame(width: 80)
            Divide()
            Placeholder(value: rate)
                .frame(width: Settings.boxWidth, height: Settings.boxHeight)
        }
    }
}

struct FirstOrderEquationView2_Preview: PreviewProvider {

    static let w: CGFloat = 250
    static let h: CGFloat = 100

    static var previews: some View {
        FirstOrderEquationView2(
            c1: 1,
            c2: 2,
            t: 1,
            rate: 1,
            halfTime: 1,
            maxWidth: 250,
            maxHeight: 100
        )
    }

}
