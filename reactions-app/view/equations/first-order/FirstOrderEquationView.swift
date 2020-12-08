//
// Reactions App
//
  

import SwiftUI

struct FirstOrderEquationView: View {

    let emphasiseFilledTerms: Bool
    let c1: CGFloat
    let c2: CGFloat?
    let t: CGFloat?
    let rate: CGFloat?
    let halfTime: CGFloat?
    let maxWidth: CGFloat
    let maxHeight: CGFloat

    private let naturalWidth: CGFloat = 314
    private let naturalHeight: CGFloat = 283

    var body: some View {
        ScaledView(
            naturalWidth: naturalWidth,
            naturalHeight: naturalHeight,
            maxWidth: maxWidth,
            maxHeight: maxHeight
        ) {
            UnscaledFirstOrderReactionEquationView(
                emphasise: emphasiseFilledTerms,
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

    let emphasise: Bool
    let c1: CGFloat
    let c2: CGFloat?
    let t: CGFloat?
    let rate: CGFloat?
    let halfTime: CGFloat?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 0) {
                FirstOrderRateFilled()
                FirstOrderRateBlank(
                    emphasise: emphasise,
                    rate: rate?.str(decimals: 2),
                    lnA0: lnStr(c1),
                    lnAt: c2.map(lnStr),
                    t: t?.str(decimals: 2)
                )
            }

            VStack(alignment: .leading, spacing: 0) {
                FirstOrderHalftimeFilled()
                FirstOrderHalftimeBlank(
                    emphasise: emphasise,
                    halftime: halfTime?.str(decimals: 2),
                    rate: rate?.str(decimals: 2)
                )
            }
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

fileprivate struct FirstOrderHalftimeFilled: View {
    var body: some View {
        HStack(spacing: 12) {
            HalfTime()
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

fileprivate struct FirstOrderHalftimeBlank: View {

    let emphasise: Bool
    let halftime: String?
    let rate: String?

    var body: some View {
        HStack(spacing: 12) {
            Placeholder(value: halftime, emphasise: emphasise)
            FixedText("=")
            HStack(spacing: 12) {
                FixedText("0.69")
                FixedText("/")
                Placeholder(value: rate, emphasise: emphasise)
            }
        }
    }
}

struct FirstOrderEquationView2_Preview: PreviewProvider {

    static let w: CGFloat = 250
    static let h: CGFloat = 100

    static var previews: some View {
        UnscaledFirstOrderReactionEquationView(
            emphasise: true,
            c1: 1,
            c2: 2,
            t: 1,
            rate: 1,
            halfTime: 1
        )
        .border(Color.red)
        .previewLayout(.fixed(width: 600, height: 600))
    }
}
