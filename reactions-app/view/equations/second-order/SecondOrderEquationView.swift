//
// Reactions App
//


import SwiftUI

struct SecondOrderEquationView: View {

    let emphasiseFilledTerms: Bool
    let c1: CGFloat
    let c2: CGFloat?
    let k: CGFloat?
    let t: CGFloat?
    let halfLife: CGFloat?
    let maxWidth: CGFloat
    let maxHeight: CGFloat

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
                k: k,
                t: t,
                halfLife: halfLife
            )
        }
        .frame(width: maxWidth, height: maxHeight)
    }
}

fileprivate struct UnscaledSecondOrderEquationView: View {

    let emphasise: Bool
    let c1: CGFloat
    let c2: CGFloat?
    let k: CGFloat?
    let t: CGFloat?
    let halfLife: CGFloat?

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            SecondOrderRateFilled()
            SecondOrderRateBlank(
                emphasise: emphasise,
                rate: k?.str(decimals: 2),
                invA0: invStr(c1),
                invAt: c2.map(invStr),
                time: t?.str(decimals: 2)
            )
            SecondOrderHalfLifeFilled()
            SecondOrderHalfLifeBlank(
                emphasise: emphasise,
                halfLife: halfLife?.str(decimals: 2),
                rate: k?.str(decimals: 2),
                a0: c1.str(decimals: 2)
            )
        }
        .font(.system(size: EquationSettings.fontSize))
        .lineLimit(1)
        .minimumScaleFactor(1)
    }

    private func invStr(_ c: CGFloat) -> String {
        (1 / c.rounded(decimals: 2)).str(decimals: 2)
    }
}

fileprivate struct SecondOrderRateFilled: View {
    var body: some View {
        HStack(spacing: 5) {
            Text("k")
                .frame(width: EquationSettings.boxWidth)
            FixedText("=")

            VStack(spacing: 1) {
                HStack(spacing: 5) {
                    inverse {
                        A_t()
                    }.frame(width: 100)
                    FixedText("-")
                    inverse {
                        A_0()
                    }.frame(width: 100)
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

    let emphasise: Bool
    let rate: String?
    let invA0: String?
    let invAt: String?
    let time: String?

    var body: some View {
        HStack(spacing: 5) {
            Placeholder(value: rate, emphasise: emphasise)

            FixedText("=")

            VStack(spacing: 1) {
                HStack(spacing: 1) {
                    Placeholder(value: invAt, emphasise: emphasise)
                        .frame(width: 100)

                    FixedText("-")

                    Placeholder(value: invA0, emphasise: invAt == nil)
                        .frame(width: 100)
                }

                Rectangle()
                    .frame(width: 225, height: 2)

                Placeholder(value: time, emphasise: emphasise)
            }
        }
    }
}

fileprivate struct SecondOrderHalfLifeFilled: View {
    var body: some View {
        HStack(spacing: 5) {
            HalfLife()
                .frame(width: EquationSettings.boxWidth)
            FixedText("=")
            FixedText("1")
            FixedText("/")
            FixedText("(k")
            A_0()
            FixedText(")")
        }
    }
}

fileprivate struct SecondOrderHalfLifeBlank: View {

    let emphasise: Bool
    let halfLife: String?
    let rate: String?
    let a0: String

    var body: some View {
        HStack(spacing: 5) {
            Placeholder(value: halfLife, emphasise: emphasise)

            FixedText("=")

            FixedText("1")

            HStack(spacing: 1) {
                FixedText("/")
                Placeholder(value: rate, emphasise: emphasise)
                FixedText("(")
                Text(a0)
                    .frame(width: EquationSettings.boxWidth * 0.8)
                    .minimumScaleFactor(0.5)
                    .foregroundColor(rate == nil ? .orangeAccent : .black)
                FixedText(")")
            }
        }
    }
}

fileprivate struct EquationSize {
    static let width: CGFloat = 327
    static let height: CGFloat = 312
}


struct SecondOrderEquationView2_Previews: PreviewProvider {
    static var previews: some View {
        UnscaledSecondOrderEquationView(
            emphasise: true,
            c1: 1.23,
            c2: 0.34,
            k: 1.45,
            t: 1.4,
            halfLife: 2.34
        )
        .border(Color.red)
        .previewLayout(.fixed(width: EquationSize.width, height: EquationSize.height))
    }
}
