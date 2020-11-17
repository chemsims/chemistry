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
            makeView(width: width(geometry: geometry))
        }
    }

    private func width(geometry: GeometryProxy) -> CGFloat {
        min(2.4 * geometry.size.height, geometry.size.width)
    }

    private func makeView(width: CGFloat) -> some View {
        HStack(spacing: width * 0.02) {
            term(rateTerm)
                .frame(
                    width: rateSize(width: width),
                    height: rateSize(width: width)
                )
            Text("=")
                .frame(width: width * 0.07)
            fraction(width: width)
        }
        .lineLimit(1)
        .font(.system(size: maxFontSize(width: width)))
        .minimumScaleFactor(0.01)
    }

    private func rateSize(width: CGFloat) -> CGFloat {
        return width * 0.2
    }

    private func maxFontSize(width: CGFloat) -> CGFloat {
        0.15 * width
    }

    private func fraction(width: CGFloat) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                term(c1)
                    .frame(width: width * 0.25, height: width * 0.2)
                Text("-")
                    .frame(width: width * 0.07)
                term(c2)
                    .frame(width: width * 0.25, height: width * 0.2)
            }
            Rectangle()
                .frame(width: width * 0.6, height: 1)
            term(t)
                .frame(width: width * 0.25, height: width * 0.2)
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
                .padding(4)
        )
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
