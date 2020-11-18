//
// Reactions App
//
  

import SwiftUI

struct ZeroOrderReactionEquation: View {

    let emphasiseFilledTerms: Bool
    let initialConcentration: CGFloat
    let initialTime: CGFloat
    let rate: CGFloat?
    let deltaC: CGFloat?
    let deltaT: CGFloat?
    let c2: CGFloat?
    let t2: CGFloat?
    let halfTime: CGFloat?
    let maxWidth: CGFloat
    let maxHeight: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZeroOrderEquationFilled(
                maxWidth: maxWidth,
                maxHeight: maxHeight / 4
            )
            ZeroOrderEquationBlank(
                emphasiseFilledTerms: emphasiseFilledTerms,
                initialConcentration: initialConcentration,
                initialTime: initialTime,
                rate: rate,
                deltaC: deltaC,
                deltaT: deltaT,
                c2: c2,
                t2: t2,
                maxWidth: maxWidth,
                maxHeight: maxHeight / 3
            )
            ZeroOrderReactionHalftimeView(
                maxWidth: maxWidth,
                maxHeight: maxHeight / 6
            )
            ZeroOrderReactionHalftimeBlank(
                initialConcentration: initialConcentration,
                rate: rate,
                halfTime: halfTime,
                maxWidth: maxWidth,
                maxHeight: 2.5 * maxHeight / 12
            )
        }
    }
}

struct ZeroOrderEquationFilled: View {

    let maxWidth: CGFloat
    let maxHeight: CGFloat

    var body: some View {
        GeneralZeroOrderReactionEquationView(
            rate: "k",
            deltaC: "Δc",
            deltaT: "Δt",
            c2: "c2",
            c1: "c1",
            t2: "t2",
            t1: "t1",
            emphasiseFilledTerms: false,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            hasPlaceholders: false
        )
    }
}

struct ZeroOrderEquationBlank: View {

    /// Scales the view
    let scale: CGFloat = 1
    let emphasiseFilledTerms: Bool

    let initialConcentration: CGFloat
    let initialTime: CGFloat
    let rate: CGFloat?
    let deltaC: CGFloat?
    let deltaT: CGFloat?
    let c2: CGFloat?
    let t2: CGFloat?

    let maxWidth: CGFloat
    let maxHeight: CGFloat

    var body: some View {
        GeneralZeroOrderReactionEquationView(
            rate: rate?.str(decimals: 2),
            deltaC: deltaC?.str(decimals: 2),
            deltaT: deltaT?.str(decimals: 2),
            c2: c2?.str(decimals: 2),
            c1: initialConcentration.str(decimals: 2),
            t2: t2?.str(decimals: 2),
            t1: initialTime.str(decimals: 2),
            emphasiseFilledTerms: emphasiseFilledTerms,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            hasPlaceholders: true
        )
    }
}


struct EquationGeometrySettings {
    let maxWidth: CGFloat
    let maxHeight: CGFloat

    var width: CGFloat {
        return maxWidth
    }

    var rateWidth: CGFloat {
        width * 0.1
    }
    var equalsWidth: CGFloat {
        width * 0.03
    }

    var fractionBoxHeight: CGFloat {
        let maxBoxHeight = (maxHeight - 1) / 2
        return min(boxWidth * 0.75, maxBoxHeight)
    }

    var boxWidth: CGFloat {
        width * 0.12
    }
    var boxHeight: CGFloat {
        boxWidth * 0.75
    }
    var negativeWidth: CGFloat {
        equalsWidth
    }
    var boxPadding: CGFloat {
        boxWidth * 0.3
    }
    var fraction1DividerWidth: CGFloat {
        width * 0.06
    }
    var fontSize: CGFloat {
        width * 0.04
    }
    var fraction2DividerWidth: CGFloat {
        width * 0.25
    }
    var parenWidth: CGFloat {
        equalsWidth
    }
    var subscriptFontSize: CGFloat {
        fontSize * 0.6
    }
    var subscriptBaselineOffset: CGFloat {
        fontSize * -0.4
    }

    var halfTimeHeight: CGFloat {
        min(boxWidth * 0.8, maxHeight)
    }

    var halfTimeWidth: CGFloat {
        boxWidth
    }
}


fileprivate struct GeneralZeroOrderReactionEquationView: View {

    let rate: String?
    let deltaC: String?
    let deltaT: String?

    let c2: String?
    let c1: String

    let t2: String?
    let t1: String

    let emphasiseFilledTerms: Bool

    let maxWidth: CGFloat
    let maxHeight: CGFloat

    let hasPlaceholders: Bool

    var body: some View {
        makeView(
            settings: EquationGeometrySettings(
                maxWidth: maxWidth,
                maxHeight: maxHeight
            )
        )
    }

    private func makeView(settings: EquationGeometrySettings) -> some View {
        HStack(spacing: 0) {
            Text("Rate")
                .frame(width: settings.rateWidth)
            Text("=")
                .frame(width: settings.equalsWidth)
            termOrBox(rate, settings: settings)
                .frame(minWidth: settings.boxWidth)
                .foregroundColor(colorForTerm(rate))

            Text("=")
                .frame(width: settings.equalsWidth)

            fraction1(settings: settings)

            Text("=")
                .frame(width: settings.equalsWidth)

            fraction2(settings: settings)
        }
        .font(.system(size: settings.fontSize))
        .minimumScaleFactor(0.2)
        .lineLimit(1)
    }

    private func fraction1(settings: EquationGeometrySettings) -> some View {
        HStack(spacing: 0) {
            Text("–")
                .frame(width: settings.negativeWidth)
            VStack(spacing: 0) {
                termOrBox(deltaC, settings: settings)
                    .equationBox(
                        width: settings.boxWidth,
                        height: hasPlaceholders ? settings.fractionBoxHeight : nil
                    )
                    .foregroundColor(colorForTerm(deltaC))

                divider
                    .frame(width: settings.fraction1DividerWidth)

                termOrBox(deltaT, settings: settings)
                    .equationBox(
                        width: settings.boxWidth,
                        height: hasPlaceholders ? settings.fractionBoxHeight : nil
                    )
                    .foregroundColor(colorForTerm(deltaC))
            }
        }
    }

    private func fraction2(settings: EquationGeometrySettings) -> some View {
        HStack(spacing: 0) {
            Text("–")
                .frame(width: settings.negativeWidth)
            VStack(spacing: 0) {
                fraction2Part(term1: c2, term2: c1, settings: settings)
                divider
                    .frame(width: settings.fraction2DividerWidth)
                fraction2Part(term1: t2, term2: t1, settings: settings)
            }
        }
    }

    private func fraction2Part(
        term1: String?,
        term2: String,
        settings: EquationGeometrySettings
    ) -> some View {
        HStack(spacing: 1) {

            termOrBox(term1, settings: settings)
                .equationBox(
                    width: settings.boxWidth,
                    height: hasPlaceholders ? settings.fractionBoxHeight : nil
                )
                .foregroundColor(colorForTerm(term1))

            Text("–")
                .frame(width: settings.negativeWidth)


            Text(term2)
                .equationBox(
                    width: settings.boxWidth,
                    height: hasPlaceholders ? settings.fractionBoxHeight : nil
                ).foregroundColor(emphasisColor)

        }
    }

    private var divider: some View {
        Rectangle().frame(height: 1)
    }

    private func colorForTerm(_ term: String?) -> Color {
        if term == nil {
            return .black
        }
        return emphasisColor
    }

    private var emphasisColor: Color {
        emphasiseFilledTerms ? .orangeAccent : .black
    }
}

struct BoxFramingModifier: ViewModifier {
    let width: CGFloat
    let height: CGFloat?

    func body(content: Content) -> some View {
        if let height = height {
            return content.frame(
                minWidth: width,
                minHeight: height,
                maxHeight: height
            )
        }
        return content.frame(minWidth: width)
    }
}

extension View {
    func equationBox(
        width: CGFloat,
        height: CGFloat?
    ) -> some View {
        self.modifier(
            BoxFramingModifier(
                width: width,
                height: height
            )
        )
    }
}


struct Equation_Previews: PreviewProvider {
    static var previews: some View {
        ZeroOrderReactionEquation(
            emphasiseFilledTerms: true,
            initialConcentration: 0.1,
            initialTime: 0.2,
            rate: 0.3,
            deltaC: 0.1,
            deltaT: 0.2,
            c2: 0.2,
            t2: 0.1,
            halfTime: 1.5,
            maxWidth: 300,
            maxHeight: 400
        )
    }
}
