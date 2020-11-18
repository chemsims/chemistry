//
// Reactions App
//
  

import SwiftUI

struct SecondOrderEquationView: View {

    let c1: CGFloat
    let c2: CGFloat?
    let rate: CGFloat?
    let t: CGFloat?
    let halfTime: CGFloat?
    let maxWidth: CGFloat
    let maxHeight: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FilledSecondOrderEquationRateView(
                maxWidth: maxWidth,
                maxHeight: maxHeight / 4
            )
            BlankSecondOrderEquationRateView(
                c1: c1,
                c2: c2,
                rate: rate,
                t: t,
                maxWidth: maxWidth,
                maxHeight: maxHeight / 4
            )
            SecondOrderHalfTimeFilled(
                maxWidth: maxWidth,
                maxHeight: maxHeight / 4
            )
            SecondOrderHalfTimeBlank(
                halfTime: halfTime,
                rate: rate,
                c1: c1,
                maxWidth: maxWidth,
                maxHeight: maxHeight
            )
        }
    }

}

struct FilledSecondOrderEquationRateView: View {

    let maxWidth: CGFloat
    let maxHeight: CGFloat

    var body: some View {
        GeneralSecondOrderEquationRateView(
            c1: "1/[A0]",
            c2: "1/[At]",
            rate: "k",
            t: "t",
            maxWidth: maxWidth,
            maxHeight: maxHeight
        )
    }
}

struct BlankSecondOrderEquationRateView: View {

    let c1: CGFloat
    let c2: CGFloat?
    let rate: CGFloat?
    let t: CGFloat?
    let maxWidth: CGFloat
    let maxHeight: CGFloat

    var body: some View {
        GeneralSecondOrderEquationRateView(
            c1: c1.str(decimals: 2),
            c2: c2?.str(decimals: 2),
            rate: rate?.str(decimals: 2),
            t: t?.str(decimals: 2),
            maxWidth: maxWidth,
            maxHeight: maxHeight
        )
    }
}

struct GeneralSecondOrderEquationRateView: View {

    let c1: String?
    let c2: String?
    let rate: String?
    let t: String?
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
            settings
                .termOrBox(rate)
                .frame(width: settings.rateSize, height: settings.rateSize)

            Text("=")
                .frame(width: settings.equalsWidth)

            fraction(settings: settings)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.2)
        .font(.system(size: settings.fontSize))
    }

    private func fraction(settings: FirstOrderEquationSettings) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                settings.termOrBox(c1)
                    .frame(width: settings.term1Width, height: settings.term1Height)

                Text("-")
                    .frame(width: settings.negativeWidth)

                settings.termOrBox(c2)
                    .frame(width: settings.term1Width, height: settings.term1Height)
            }

            Rectangle()
                .frame(width: settings.rateDividerWidth, height: 1)

            settings.termOrBox(t)
                .frame(width: settings.term1Width, height: settings.term1Height)
        }
    }
}


