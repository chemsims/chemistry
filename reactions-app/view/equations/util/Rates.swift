//
// Reactions App
//
  

import SwiftUI

struct BlankRate: View {
    let order: Int
    var body: some View {
        HStack(spacing: 4) {
            FixedText("Rate")
            FixedText("=")
            FixedText("k")
            HStack(spacing: 0) {
                FixedText("[A]")
                FixedText("\(order)")
                    .font(.system(size: EquationSettings.subscriptFontSize))
                    .offset(y: -10)
            }
        }
    }
}

struct FilledRate: View {

    let reactionHasStarted: Bool
    let currentTime: CGFloat?
    let concentration: ConcentrationEquation?
    let rateConstant: String?
    let rate: String?
    let emphasise: Bool

    var body: some View {
        HStack(spacing: 4) {
            value(equation: concentration?.rateEquation)
                .foregroundColor(reactionHasStarted ? .orangeAccent : .black)
            FixedText("=")
            Placeholder(value: rateConstant, emphasise: emphasise)
            HStack(spacing: 0) {
                FixedText("(")
                value(equation: concentration)
                    .foregroundColor(reactionHasStarted ? .orangeAccent : .black)
                FixedText(")")
                FixedText("0")
                    .font(.system(size: EquationSettings.subscriptFontSize))
                    .offset(y: -10)
            }
        }
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
        VStack {
            BlankRate(order: 1)
        }
    }
}
