//
// Reactions App
//
  

import SwiftUI

struct FirstOrderHalftimeEquationFilled: View {
    var body: some View {
        GeneralFirstOrderHalftimeEquation(
            halfTime: "t1/2",
            ln2: "ln(2)",
            rate: "k"
        )
    }
}

struct FirstOrderHalftimeEquationBlank: View {
    let halfTime: CGFloat?
    let rate: CGFloat?

    var body: some View {
        GeneralFirstOrderHalftimeEquation(
            halfTime: halfTime?.str(decimals: 2),
            ln2: "0.69",
            rate: rate?.str(decimals: 2)
        )
    }
}


struct GeneralFirstOrderHalftimeEquation: View {

    let halfTime: String?
    let ln2: String
    let rate: String?

    var body: some View {
        GeometryReader { geometry in
            makeView(settings: FirstOrderEquationSettings(geometry: geometry))
        }
    }

    private func makeView(settings: FirstOrderEquationSettings) -> some View {
        HStack(spacing: 0) {
            settings
                .termOrBox(halfTime)
                .frame(width: settings.rateSize, height: settings.rateSize)
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

struct FirstOrderHalftimeEquation_Previews: PreviewProvider {
    static var previews: some View {
        FirstOrderHalftimeEquationFilled()
    }
}
