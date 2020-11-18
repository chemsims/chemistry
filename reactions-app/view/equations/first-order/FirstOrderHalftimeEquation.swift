//
// Reactions App
//
  

import SwiftUI

struct FirstOrderHalftimeEquationFilled: View {

    let maxWidth: CGFloat
    let maxHeight: CGFloat

    var body: some View {
        GeneralFirstOrderHalftimeEquation(
            showHalfTimeFilled: true,
            halfTime: "t1/2",
            ln2: "ln(2)",
            rate: "k",
            maxWidth: maxWidth,
            maxHeight: maxHeight
        )
    }
}

struct FirstOrderHalftimeEquationBlank: View {
    let halfTime: CGFloat?
    let rate: CGFloat?

    let maxWidth: CGFloat
    let maxHeight: CGFloat

    var body: some View {
        GeneralFirstOrderHalftimeEquation(
            showHalfTimeFilled: false,
            halfTime: halfTime?.str(decimals: 2),
            ln2: "0.69",
            rate: rate?.str(decimals: 2),
            maxWidth: maxWidth,
            maxHeight: maxHeight
        )
    }
}


struct GeneralFirstOrderHalftimeEquation: View {

    let showHalfTimeFilled: Bool
    let halfTime: String?
    let ln2: String
    let rate: String?

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
            if (showHalfTimeFilled) {
                SubscriptView(
                    main: "t",
                    subscriptComponent: "1/2",
                    mainFontSize: settings.fontSize,
                    subscriptFontSize: settings.subscriptFontSize,
                    subscriptBaselineOffset: settings.subscriptBaselineOffset
                )
            } else {
                settings
                    .termOrBox(halfTime)
                    .frame(width: settings.rateSize, height: settings.rateSize)
            }

            Text("=")
                .frame(width: settings.equalsWidth)
            Text(ln2)
                .frame(width: settings.term1Width)
            Text("/")
                .frame(width: settings.equalsWidth)
            settings.termOrBox(rate)
                .frame(width: settings.rateSize, height: settings.rateSize)
        }
        .lineLimit(1)
        .font(.system(size: settings.fontSize))
        .minimumScaleFactor(0.01)
    }
}
