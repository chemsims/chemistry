//
// Reactions App
//
  

import SwiftUI

struct SecondOrderHalfTimeFilled: View {

    let maxWidth: CGFloat
    let maxHeight: CGFloat

    var body: some View {
        GeneralSecondOrderHalfTimeView(
            showFilled: true,
            halfTime: nil,
            rate: nil,
            c1: "a0",
            maxWidth: maxWidth,
            maxHeight: maxHeight
        )
    }
}

struct SecondOrderHalfTimeBlank: View {

    let halfTime: CGFloat?
    let rate: CGFloat?
    let c1: CGFloat
    let maxWidth: CGFloat
    let maxHeight: CGFloat

    var body: some View {
        GeneralSecondOrderHalfTimeView(
            showFilled: false,
            halfTime: halfTime?.str(decimals: 2),
            rate: rate?.str(decimals: 2),
            c1: c1.str(decimals: 2),
            maxWidth: maxWidth,
            maxHeight: maxHeight
        )
    }

}

struct GeneralSecondOrderHalfTimeView: View {

    let showFilled: Bool
    let halfTime: String?
    let rate: String?
    let c1: String
    let maxWidth: CGFloat
    let maxHeight: CGFloat

    var body: some View {
        makeView(
            settings: FirstOrderEquationSettings(
                maxWidth: maxWidth,
                maxHeight: maxHeight
            )
        )
    }

    private func makeView(settings: FirstOrderEquationSettings) -> some View {
        HStack(spacing: 0) {
            if (showFilled) {
                Text("t1/2")
                    .frame(width: settings.rateSize)
            } else {
                settings.termOrBox(rate)
                    .frame(width: settings.rateSize, height: settings.rateSize)
            }

            Text("=")
                .frame(width: settings.equalsWidth)

            Text("1")
                .frame(width: settings.equalsWidth)

            Text("/")
                .frame(width: settings.negativeWidth)

            if (showFilled) {
                    Text("(k[A0])")
                        .frame(width: 1.2 * settings.boxSize)
            } else {
                settings
                    .termOrBox(rate)
                    .frame(width: settings.boxSize)

                Text("(")
                settings
                    .termOrBox(c1)
                    .frame(width: settings.boxSize)
                Text(")")
            }
        }
        .font(.system(size: settings.fontSize))
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }
}

