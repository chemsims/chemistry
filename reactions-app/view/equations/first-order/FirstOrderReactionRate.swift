//
// Reactions App
//
  

import SwiftUI

struct FirstOrderReactionEquation: View {

    let c1: CGFloat
    let c2: CGFloat?
    let t: CGFloat?
    let rate: CGFloat?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FirstOrderReactionRateFilled()
            FirstOrderReactionRateBlank(c1: c1, c2: c2, t: t, rate: rate)
            FirstOrderReactionRateFilled()
            FirstOrderReactionRateFilled()
        }
    }
}

fileprivate struct FirstOrderReactionRateFilled: View {

    var body: some View {
        GeneralFirstOrderReactionRate(
            rateTerm: "k",
            c1: "ln[A0]",
            c2: "ln[At]",
            t: "t"
        )
    }
}

fileprivate struct FirstOrderReactionRateBlank: View {

    let c1: CGFloat
    let c2: CGFloat?
    let t: CGFloat?
    let rate: CGFloat?

    var body: some View {
        GeneralFirstOrderReactionRate(
            rateTerm: rate?.str(decimals: 2),
            c1: "(\(c1.str(decimals: 2)))",
            c2: c2.map { s in "(\(s.str(decimals: 2)))"},
            t: t?.str(decimals: 2)
        )
    }
}

fileprivate struct GeneralFirstOrderReactionRate: View {
    
    let rateTerm: String?
    let c1: String?
    let c2: String?
    let t: String?

    var body: some View {
        GeometryReader { geometry in
            makeView(
                settings: FirstOrderEquationSettings(geometry: geometry)
            )
        }
    }

    private func makeView(settings: FirstOrderEquationSettings) -> some View {
        HStack(spacing: settings.hStackSpacing) {
            term(rateTerm)
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
        .minimumScaleFactor(0.01)
    }

    private func fraction(settings: FirstOrderEquationSettings) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                term(c1)
                    .frame(width: settings.term1Width, height: settings.term1Height)
                Text("-")
                    .frame(width: settings.negativeWidth)
                term(c2)
                    .frame(width: settings.term1Width, height: settings.term1Height)
            }
            Rectangle()
                .frame(width: settings.rateDividerWidth, height: 1)
            term(t)
                .frame(width: settings.term1Width, height: settings.term1Height)
        }
    }

    func term(_ t: String?) -> some View {
        if (t != nil) {
            return AnyView(
                Text(t!)
            )
        }
        return AnyView(
            EquationPlaceholderView()
                .padding(3)
        )
    }
}

struct FirstOrderEquationSettings {
    let geometry: GeometryProxy

    var width: CGFloat {
        min(2.4 * geometry.size.height, geometry.size.width)
    }

    var rateSize: CGFloat {
        0.2 * width
    }

    var equalsWidth: CGFloat {
        0.07 * width
    }

    var negativeWidth: CGFloat {
        0.07 * width
    }

    var fontSize: CGFloat {
        0.11 * width
    }

    var hStackSpacing: CGFloat {
        0.02 * width
    }

    var term1Width: CGFloat {
        0.25 * width
    }

    var term1Height: CGFloat {
        0.2 * width
    }

    var rateDividerWidth:CGFloat {
        0.6 * width
    }
}

struct FirstOrderReactionRate_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            FirstOrderReactionRateBlank(c1: 0.69, c2: nil, t: nil, rate: nil)
                .border(Color.red)
                .frame(width: 130, height: 100)
                .scaleEffect(x: 0.5, y: 0.5)

            FirstOrderReactionRateBlank(c1: -0.69, c2: nil, t: nil, rate: nil)
                .border(Color.red)
                .frame(width: 130, height: 100)

            FirstOrderReactionRateBlank(c1: -0.69, c2: -1.69, t: 17, rate: 0.06)
                .border(Color.red)
                .frame(width: 130, height: 100)

            FirstOrderReactionRateFilled()
                .border(Color.blue)
                .frame(width: 130, height: 100)

            FirstOrderReactionRateFilled()
                .border(Color.blue)
                .frame(width: 200, height: 150)

            FirstOrderReactionRateFilled()
                .border(Color.blue)
                .frame(width: 300)
        }
    }
}
