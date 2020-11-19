//
// Reactions App
//
  

import SwiftUI

// 534 552
struct FirstOrderEquationView2: View {

    let c1: CGFloat
    let c2: CGFloat?
    let t: CGFloat?
    let rate: CGFloat?
    let halfTime: CGFloat?
    let maxWidth: CGFloat
    let maxHeight: CGFloat

    private let naturalWidth: CGFloat = 267
    private let naturalHeight: CGFloat = 276

    var body: some View {
        ScaledView(
            naturalWidth: naturalWidth,
            naturalHeight: naturalHeight,
            maxWidth: maxWidth,
            maxHeight: maxHeight
        ) {
            VStack(alignment: .leading, spacing: 4) {
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
            .border(Color.black)
            .font(.system(size: RateEquationSizes.fontSize))
            .lineLimit(1)
        }.frame(width: maxWidth, height: maxHeight)
    }
}

fileprivate struct FirstOrderRateFilled: View {

    var body: some View {
        HStack(spacing: 1) {
            Text("k")
                .frame(width: Settings.boxWidth)
            Equals()
            VStack(spacing: 1) {
                HStack(spacing: 1) {
                    lnA {
                        A_0()
                    }
                    Minus()
                    lnA {
                        A_t()
                    }
                }
                Rectangle()
                    .frame(width: 170, height: 2)
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
        HStack(spacing: 1) {
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
                    .frame(width: 140, height: 2)
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
