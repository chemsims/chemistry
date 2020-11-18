//
// Reactions App
//


import SwiftUI

struct ZeroOrderReactionHalftimeView: View {

    let maxWidth: CGFloat
    let maxHeight: CGFloat

    var body: some View {
        GeneralZeroOrderReactionHalftimeView(
            showFilled: true,
            initialConcentration: nil,
            rate: nil,
            halfTime: nil,
            maxWidth: maxWidth,
            maxHeight: maxHeight
        )
    }
}

struct ZeroOrderReactionHalftimeBlank: View {
    let scale: CGFloat = 1

    let initialConcentration: CGFloat?
    let rate: CGFloat?
    let halfTime: CGFloat?

    let maxWidth: CGFloat
    let maxHeight: CGFloat

    var body: some View {
        GeneralZeroOrderReactionHalftimeView(
            showFilled: false,
            initialConcentration: initialConcentration?.str(decimals: 2),
            rate: rate?.str(decimals: 2),
            halfTime: halfTime?.str(decimals: 2),
            maxWidth: maxWidth,
            maxHeight: maxHeight
        )
    }
}

struct GeneralZeroOrderReactionHalftimeView: View {

    let showFilled: Bool

    let initialConcentration: String?
    let rate: String?
    let halfTime: String?

    let maxWidth: CGFloat
    let maxHeight: CGFloat

    var body: some View {
        makeView(
            settings: ZeroOrderEquationGeometry(
                maxWidth: maxWidth,
                maxHeight: maxHeight
            )
        )
    }

    private func makeView(settings: ZeroOrderEquationGeometry) -> some View {
        HStack {
            if (showFilled) {
                SubscriptView(
                    main: "t",
                    subscriptComponent: "1/2",
                    mainFontSize: settings.subscriptFontSize,
                    subscriptFontSize: settings.subscriptFontSize,
                    subscriptBaselineOffset: settings.subscriptBaselineOffset
                ).equationBox(
                    width: settings.halfTimeWidth,
                    height: settings.halfTimeHeight
                )
            } else {
                termOrBox(halfTime, settings: settings)
                    .equationBox(
                        width: settings.halfTimeWidth,
                        height: settings.halfTimeHeight
                    ).frame(width: settings.halfTimeWidth)
            }

            Text("=")
            if (showFilled) {
                filledInitialConcentrationView(settings: settings)
            } else {
                initialConcentrationView(settings: settings)
            }
            Text("/")
            rateView(settings: settings)
        }.font(.system(size: settings.fontSize))
    }

    private func filledInitialConcentrationView(settings: ZeroOrderEquationGeometry) -> some View {
        HStack(spacing: 1) {
            Text("[")
            SubscriptView(
                main: "A",
                subscriptComponent: "0",
                mainFontSize: settings.subscriptFontSize,
                subscriptFontSize: settings.subscriptFontSize,
                subscriptBaselineOffset: settings.subscriptBaselineOffset
            )
            Text("]")
        }.equationBox(
            width: settings.halfTimeWidth,
            height: settings.halfTimeHeight
        )
    }

    private func initialConcentrationView(settings: ZeroOrderEquationGeometry)-> some View {
        termOrBox(initialConcentration, settings: settings)
            .foregroundColor(rate == nil ? .black : .orangeAccent)
            .equationBox(
                width: settings.halfTimeWidth,
                height: settings.halfTimeHeight
            )
    }

    private func rateView(settings: ZeroOrderEquationGeometry) -> some View {
        HStack(spacing: 2) {
            Text("(")
            Text("2")
            if (showFilled) {
                Text("k")
            } else {
                if (rate != nil) {
                    Text("x")
                        .frame(width: settings.equalsWidth)
                }
                termOrBox(rate, settings: settings)
                    .foregroundColor(rate == nil ? .black : .orangeAccent)
                    .equationBox(
                        width: settings.halfTimeWidth,
                        height: settings.halfTimeHeight
                    )
            }
            Text(")")
        }
    }
}


