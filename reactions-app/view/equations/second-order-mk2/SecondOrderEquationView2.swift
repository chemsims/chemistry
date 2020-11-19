//
// Reactions App
//


import SwiftUI

// 649 548
// 325 274
struct SecondOrderEquationView2: View {

    let c1: CGFloat
    let c2: CGFloat?
    let rate: CGFloat?
    let t: CGFloat?
    let halfTime: CGFloat?
    let maxWidth: CGFloat
    let maxHeight: CGFloat

    private let naturalWidth: CGFloat = 342
    private let naturalHeight: CGFloat = 310
    

    var body: some View {
        ScaledView(
            naturalWidth: naturalWidth,
            naturalHeight: naturalHeight,
            maxWidth: maxWidth,
            maxHeight: maxHeight
        ) {
            VStack(alignment: .leading, spacing: 15) {
                SecondOrderRateFilled()
                SecondOrderRateBlank(
                    rate: rate?.str(decimals: 2),
                    a0: c1.str(decimals: 2),
                    at: c2?.str(decimals: 2),
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
            .minimumScaleFactor(0.5)
        }.frame(width: maxWidth, height: maxHeight)
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
                        A_0()
                    }
                    Minus()
                    inverse {
                        A_t()
                    }
                }
                Rectangle()
                    .frame(width: 225, height: 2)
                Text("t")
                    .frame(width: 10)
            }
        }
    }


    private func inverse<Content: View>(aTerm: () -> Content) -> some View {
        HStack(spacing: 0) {
            Text("(1/")
                .frame(width: 36)
            aTerm()
            Text(")")
                .frame(width: 17)
        }
    }
}

fileprivate struct SecondOrderRateBlank: View {

    let rate: String?
    let a0: String?
    let at: String?
    let time: String?

    var body: some View {
        HStack(spacing: 5) {
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
                    .frame(width: 180, height: 2)

                Placeholder(value: time)
                    .frame(width: Settings.boxWidth, height: Settings.boxHeight)
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
                .frame(width: 20)
            Divide()
            Text("(k")
                .frame(width: 32)
            A_0()
            Text(")")
                .frame(width: 18)
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

            Equals()

            Text("1")
                .frame(width: 20)
            Divide()

            Placeholder(value: rate)
                .frame(width: Settings.boxWidth, height: Settings.boxHeight)

            if (a0 != nil) {
                Text("(")
                    .frame(width: 12)

                Text(a0!)
                    .frame(width: 64)
                Text(")")
                    .frame(width: 13)
            } else {
                Box()
                    .frame(width: Settings.boxWidth, height: Settings.boxHeight)
            }
        }
    }
}


struct SecondOrderEquationView2_Previews: PreviewProvider {
    static var previews: some View {
        SecondOrderEquationView2(
            c1: 1,
            c2: 1,
            rate: 1,
            t: 1,
            halfTime: 1,
            maxWidth: 1,
            maxHeight: 1
        ).previewLayout(.fixed(width: 600, height: 400))
    }
}
