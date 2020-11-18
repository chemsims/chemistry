//
// Reactions App
//
  

import SwiftUI

struct FirstOrderReactionEquation: View {

    let c1: CGFloat
    let c2: CGFloat?
    let t: CGFloat?
    let rate: CGFloat?
    let halfTime: CGFloat?

    let maxWidth: CGFloat
    let maxHeight: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FirstOrderReactionRateFilled(
                maxWidth: maxWidth,
                maxHeight: maxHeight
            )
            FirstOrderReactionRateBlank(
                c1: c1,
                c2: c2,
                t: t,
                rate: rate,
                maxWidth: maxWidth,
                maxHeight: maxHeight
            )
            FirstOrderHalftimeEquationFilled(
                maxWidth: maxWidth,
                maxHeight: maxHeight
            )
            FirstOrderHalftimeEquationBlank(
                halfTime: halfTime,
                rate: rate,
                maxWidth: maxWidth,
                maxHeight: maxHeight
            )
        }
    }
}

fileprivate struct FirstOrderReactionRateFilled: View {

    let maxWidth: CGFloat
    let maxHeight: CGFloat

    var body: some View {
        GeneralFirstOrderReactionRate(
            rateTerm: "k",
            c1: "ln[c1]",
            c2: "ln[c2]",
            t: "t",
            maxWidth: maxWidth,
            maxHeight: maxHeight
        )
    }
}

fileprivate struct FirstOrderReactionRateBlank: View {

    let c1: CGFloat
    let c2: CGFloat?
    let t: CGFloat?
    let rate: CGFloat?

    let maxWidth: CGFloat
    let maxHeight: CGFloat

    var body: some View {
        GeneralFirstOrderReactionRate(
            rateTerm: rate?.str(decimals: 2),
            c1: lnC1,
            c2: lnC2,
            t: t?.str(decimals: 2),
            maxWidth: maxWidth,
            maxHeight: maxHeight
        )
    }

    private var lnC1: String {
        "(\(log(c1).str(decimals: 2)))"
    }

    private var lnC2: String? {
        if let c2 = c2 {
            return "(\(log(c2).str(decimals: 2)))"
        }
        return nil
    }
}

fileprivate struct GeneralFirstOrderReactionRate: View {
    
    let rateTerm: String?
    let c1: String?
    let c2: String?
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
        HStack(spacing: settings.hStackSpacing) {
            settings.termOrBox(rateTerm)
                .frame(
                    width: settings.rateSize,
                    height: settings.rateSize
                )
            Text("=")
                .frame(width: settings.equalsWidth)
            fraction(settings: settings)
        }
        .lineLimit(1)
        .font(.system(size: settings.fontSize))
        .minimumScaleFactor(0.2)
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
