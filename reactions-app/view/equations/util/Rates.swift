//
// Reactions App
//
  

import SwiftUI

struct BlankRate: View {

    let order: Int
    let alignWithFilled: Bool = true

    var body: some View {
        HStack(spacing: 4) {
            FixedText("Rate")
                .frame(width: EquationSettings.boxWidth)
            FixedText("=")
            FixedText("k")
                .padding(.leading, 10)
            HStack(spacing: 0) {
                FixedText("[A]")
                FixedText("\(order)")
                    .font(.system(size: EquationSettings.subscriptFontSize))
                    .offset(y: -10)
            }
        }.font(.system(size: EquationSettings.fontSize))
    }

    private func aligned<Content: View>(width: CGFloat, v: () -> Content) -> some View {
        if (alignWithFilled) {
            return AnyView(v()
                            .frame(width: width)
            )
        }
        return AnyView( v())
    }
}

struct FilledRate: View {

    let reactionHasStarted: Bool
    let currentTime: CGFloat?
    let concentration: ConcentrationEquation?
    let emphasise: Bool

    var body: some View {
        HStack(spacing: 4) {
            value(equation: concentration?.rateEquation)
                .foregroundColor(reactionHasStarted ? .orangeAccent : .black)
            FixedText("=")
            Placeholder(
                value: concentration?.rateConstant.str(decimals: 3),
                emphasise: emphasise
            )
            HStack(spacing: 0) {
                FixedText("(")
                value(equation: concentration)
                    .foregroundColor(reactionHasStarted ? .orangeAccent : .black)
                FixedText(")")
                FixedText("0")
                    .font(.system(size: EquationSettings.subscriptFontSize))
                    .offset(y: -10)
            }
        }.font(.system(size: EquationSettings.fontSize))
    }

    private func value(equation: Equation?) -> some View {
        if (currentTime == nil || equation == nil) {
            return AnyView(Placeholder(value: nil))
        }
        return AnyView(
            AnimatingNumber(
                x: currentTime!,
                equation: equation!,
                formatter: { $0.str(decimals: 2) },
                alignment: .leading
            )
            .frame(width: EquationSettings.boxWidth)
            .minimumScaleFactor(0.5)
        )
    }
}

struct Rates_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading) {
            BlankRate(order: 1)
            FilledRate(
                reactionHasStarted: false,
                currentTime: nil,
                concentration: nil,
                emphasise: false
            )
        }
    }
}
