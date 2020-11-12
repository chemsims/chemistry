//
// Reactions App
//


import SwiftUI

struct ZeroOrderReactionHalftimeView: View {
    let scale: CGFloat

    var body: some View {
        GeneralZeroOrderReactionHalftimeView(
            settings: EquationGeometrySettings(scale: scale),
            showFilled: true,
            initialConcentration: nil,
            rate: nil,
            halfTime: nil
        )
    }
}

struct ZeroOrderReactionHalftimeBlank: View {
    let scale: CGFloat

    let initialConcentration: String?
    let rate: String?
    let halfTime: String?

    var body: some View {
        GeneralZeroOrderReactionHalftimeView(
            settings: EquationGeometrySettings(scale: scale),
            showFilled: false,
            initialConcentration: initialConcentration,
            rate: rate,
            halfTime: halfTime
        )
    }
}

struct GeneralZeroOrderReactionHalftimeView: View {

    let settings: EquationGeometrySettings

    let showFilled: Bool

    let initialConcentration: String?
    let rate: String?
    let halfTime: String?

    var body: some View {
        HStack {
            if (showFilled) {
                SubscriptView(
                    settings: settings,
                    main: "t",
                    subscriptComponent: "1/2"
                ).frame(width: settings.boxSize)
            } else {
                DefaultPlaceholder(settings: settings)
            }

            Text("=")
            if (showFilled) {
                filledInitialConcentrationView
            } else {
                initialConcentrationView
            }
            Text("/")
            rateView
        }.font(.system(size: settings.fontSize))
    }

    private var filledInitialConcentrationView: some View {
        HStack(spacing: 1) {
            Text("[")
            SubscriptView(
                settings: settings,
                main: "A",
                subscriptComponent: "0"
            )
            Text("]")
        }.frame(width: settings.boxSize)
    }

    private var initialConcentrationView: some View {
        termOrBox(initialConcentration, settings: settings)
            .frame(minWidth: settings.boxSize)
            .foregroundColor(rate == nil ? .black : .orangeAccent)
    }

    private var rateView: some View {
        HStack(spacing: 2) {
            Text("(")
            Text("2")
            if (showFilled) {
                Text("k")
            } else {
                if (rate != nil) {
                    Text("x")
                        .padding(.horizontal, 4)
                }
                termOrBox(rate, settings: settings)
                    .frame(minWidth: settings.boxSize)
                    .foregroundColor(rate == nil ? .black : .orangeAccent)
            }
            Text(")")
        }
    }
}

struct ZeroOrderReactionHalftimeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ZeroOrderReactionHalftimeView(scale: 2)
            ZeroOrderReactionHalftimeBlank(
                scale: 2,
                initialConcentration: nil,
                rate: nil,
                halfTime: nil
            )
            ZeroOrderReactionHalftimeBlank(
                scale: 2,
                initialConcentration: "0.2",
                rate: nil,
                halfTime: nil
            )
            ZeroOrderReactionHalftimeBlank(
                scale: 2,
                initialConcentration: "0.2",
                rate: "0.03",
                halfTime: "8.33"
            )

        }
    }
}

