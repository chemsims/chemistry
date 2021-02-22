//
// Reactions App
//

import SwiftUI

struct BlankRate: View {

    let order: Int
    let reactant: String
    let alignWithFilled: Bool = true

    var body: some View {
        HStack(spacing: 4) {
            FixedText("Rate")
                .frame(width: EquationSettings.boxWidth)
            FixedText("=")
            FixedText("k")
                .padding(.leading, 10)
            HStack(spacing: 0) {
                FixedText("[\(reactant)]")
                FixedText("\(order)")
                    .font(.system(size: EquationSettings.subscriptFontSize))
                    .offset(y: -10)
            }
        }
        .font(.system(size: EquationSettings.fontSize))
        .accessibilityElement()
        .accessibility(
            label: Text(
                "Rate equals k, times concentration of \(reactant) to the power of \(order)"
            )
        )
    }

    private func aligned<Content: View>(width: CGFloat, v: () -> Content) -> some View {
        if alignWithFilled {
            return AnyView(v()
                            .frame(width: width)
            )
        }
        return AnyView( v())
    }
}

struct FilledRate: View {

    let order: Int
    let reactionHasStarted: Bool
    let currentTime: CGFloat?
    let concentration: ConcentrationEquation?
    let emphasise: Bool
    let reactant: String

    var body: some View {
        HStack(spacing: 4) {
            value(equation: concentration?.rateEquation)
                .foregroundColor(reactionHasStarted ? .orangeAccent : .black)
                .accessibility(label: Text("Rate"))
                .accessibility(addTraits: order == 0 ? [] : .updatesFrequently)

            FixedText("=")

            Placeholder(
                value: concentration?.rateConstant.str(decimals: 3),
                emphasise: emphasise
            )
            .accessibility(label: Text("k"))

            HStack(spacing: 0) {
                FixedText("(")
                    .accessibility(label: Text(Labels.openParen))

                value(equation: concentration)
                    .foregroundColor(reactionHasStarted ? .orangeAccent : .black)
                    .accessibility(label: Text("Concentration of \(reactant)"))
                    .accessibility(addTraits: .updatesFrequently)

                FixedText(")")
                    .accessibility(label: Text(Labels.closedParen))

                FixedText("\(order)")
                    .font(.system(size: EquationSettings.subscriptFontSize))
                    .offset(y: -10)
                    .accessibility(label: Text("To the power of \(order)"))
            }
        }.font(.system(size: EquationSettings.fontSize))
    }

    private func value(equation: Equation?) -> some View {
        if currentTime == nil || equation == nil {
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
            BlankRate(order: 1, reactant: "B")
            FilledRate(
                order: 0,
                reactionHasStarted: false,
                currentTime: nil,
                concentration: nil,
                emphasise: false,
                reactant: "A"
            )
        }
    }
}
