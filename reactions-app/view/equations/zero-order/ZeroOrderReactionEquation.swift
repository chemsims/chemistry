//
// Reactions App
//
  

import SwiftUI

struct ZeroOrderEquationFilled: View {

    /// Scales the view
    let scale: CGFloat

    var body: some View {
        GeneralZeroOrderReactionEquationView(
            settings: EquationGeometrySettings(scale: scale),
            rate: "k",
            deltaC: "Δc",
            deltaT: "Δt",
            c2: "c2",
            c1: "c1",
            t2: "t2",
            t1: "t1",
            emphasiseFractionTerm2: false
        )
    }
}

struct ZeroOrderEquationBlank: View {

    /// Scales the view
    let scale: CGFloat

    let initialConcentration: Double
    let initialTime: Double
    let rate: Double?
    let deltaC: Double?
    let deltaT: Double?
    let c2: Double?
    let t2: Double?

    var body: some View {
        GeneralZeroOrderReactionEquationView(
            settings: EquationGeometrySettings(scale: scale),
            rate: rate?.str(decimals: 3),
            deltaC: deltaC?.str(decimals: 2),
            deltaT: deltaT?.str(decimals: 2),
            c2: c2?.str(decimals: 2),
            c1: initialConcentration.str(decimals: 2),
            t2: t2?.str(decimals: 2),
            t1: initialTime.str(decimals: 2),
            emphasiseFractionTerm2: true
        )
    }
}

struct GeneralZeroOrderReactionEquationView: View {

    let settings: EquationGeometrySettings

    let rate: String?
    let deltaC: String?
    let deltaT: String?

    let c2: String?
    let c1: String

    let t2: String?
    let t1: String

    let emphasiseFractionTerm2: Bool

    private var fraction1DividerWidth: CGFloat {
        30 * settings.scale
    }
    private var fraction2DividerWidth: CGFloat {
        110 * settings.scale
    }

    var body: some View {
        HStack {
            Text("Rate")
            Text("=")
            termOrBox(rate, settings: settings)
                .frame(minWidth: settings.boxSize)

            Text("=")

            fraction1

            Text("=")

            fraction2
        }
        .font(.system(size: settings.fontSize))
    }

    private var fraction1: some View {
        HStack(spacing: 0) {
            Text("–")
                .frame(width: settings.negativeWidth)
            VStack(spacing: 0) {
                HStack(spacing: 1) {
                    termOrBox(deltaC, settings: settings)
                        .frame(minWidth: settings.boxSize, minHeight: settings.boxSize)
                }
                divider
                    .frame(width: fraction1DividerWidth)

                HStack(spacing: 1) {
                    termOrBox(deltaT, settings: settings)
                        .frame(minWidth: settings.boxSize, minHeight: settings.boxSize)
                }

            }
        }
    }

    private var fraction2: some View {
        HStack(spacing: 0) {
            Text("–")
                .frame(width: settings.negativeWidth)
            VStack(spacing: 1) {
                fraction2Part(term1: c2, term2: c1)
                divider
                    .frame(width: fraction2DividerWidth)
                fraction2Part(term1: t2, term2: t1)
            }
        }
    }

    private func fraction2Part(
        term1: String?,
        term2: String
    ) -> some View {
        HStack(spacing: 1) {
            Text("(")
                .frame(width: settings.parenWidth)

            termOrBox(term1, settings: settings)
                .frame(minWidth: settings.boxSize, minHeight: settings.boxSize)

            Text("–")
                .frame(width: settings.negativeWidth)

            Text(term2)
                .frame(minWidth: settings.boxSize, minHeight: settings.boxSize)
                .foregroundColor(emphasiseFractionTerm2 ? .orangeAccent : .black)

            Text(")")
                .frame(width: settings.parenWidth)
        }
    }

    private var divider: some View {
        Rectangle().frame(height: 1)
    }
}


struct Equation_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ZeroOrderEquationFilled(scale: 1)
        }
    }
}
