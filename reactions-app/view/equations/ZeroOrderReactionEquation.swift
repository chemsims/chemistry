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
            firstTerm: "k",
            numerator1: "Δc",
            denominator1: "Δt",
            numerator2Term1: "c2",
            numerator2Term2: "c1",
            denominator2Term1: "t2",
            denominator2Term2: "t1",
            emphasiseFractionTerm2: false
        )
    }
}

struct ZeroOrderEquationTerm2Blank: View {

    /// Scales the view
    let scale: CGFloat

    let initialConcentration: Double
    let intialTime: Double

    var body: some View {
        GeneralZeroOrderReactionEquationView(
            settings: EquationGeometrySettings(scale: scale),
            firstTerm: nil,
            numerator1: nil,
            denominator1: nil,
            numerator2Term1: nil,
            numerator2Term2: String(format: "%.1f", initialConcentration),
            denominator2Term1: nil,
            denominator2Term2: String(format: "%.1f", intialTime),
            emphasiseFractionTerm2: true
        )
    }
}

struct GeneralZeroOrderReactionEquationView: View {

    let settings: EquationGeometrySettings

    let firstTerm: String?
    let numerator1: String?
    let denominator1: String?

    let numerator2Term1: String?
    let numerator2Term2: String

    let denominator2Term1: String?
    let denominator2Term2: String

    let emphasiseFractionTerm2: Bool

    private var fraction1DividerWidth: CGFloat {
        30 * settings.scale
    }
    private var fraction2DividerWidth: CGFloat {
        90 * settings.scale
    }

    var body: some View {
        HStack {
            Text("Rate")
            Text("=")
            termOrBox(firstTerm)
                .frame(minWidth: settings.scale)

            Text("=")

            fraction1

            Text("=")

            fraction2
        }.font(.system(size: settings.fontSize))
    }

    private var fraction1: some View {
        VStack(spacing: 0) {
            HStack(spacing: 1) {
                Text("–")
                    .frame(width: settings.negativeWidth)
                termOrBox(numerator1)
                    .frame(minWidth: settings.boxSize)
                Text("")
                    .frame(width: settings.negativeWidth)
            }
            divider
                .frame(width: fraction1DividerWidth)

            HStack(spacing: 1) {
                Text("")
                    .frame(width: settings.negativeWidth)
                termOrBox(denominator1)
                    .frame(minWidth: settings.boxSize)
                Text("")
                    .frame(width: settings.negativeWidth)
            }

        }.frame(minWidth: fraction1DividerWidth + 30)
    }

    private var fraction2: some View {
        VStack(spacing: 1) {
            fraction2Part(term1: numerator2Term1, term2: numerator2Term2, isNegative: true)
            divider
                .frame(width: fraction2DividerWidth)
            fraction2Part(term1: denominator2Term1, term2: denominator2Term2, isNegative: false)
        }
    }

    private func fraction2Part(
        term1: String?,
        term2: String,
        isNegative: Bool
    ) -> some View {
        HStack(spacing: 1) {
            Text("\(isNegative ? "–" : "")")
                .frame(width: settings.negativeWidth)

            Text("(")
                .frame(width: settings.parenWidth)

            termOrBox(term1)
                .frame(minWidth: settings.boxSize)

            Text("–")
                .frame(width: settings.negativeWidth)

            Text(term2)
                .frame(minWidth: settings.boxSize)
                .foregroundColor(emphasiseFractionTerm2 ? .orangeAccent : .black)

            Text(")")
                .frame(width: settings.parenWidth)

            Text("")
                .frame(width: settings.negativeWidth)
        }
    }

    private func termOrBox(_ term: String?) -> some View {
        if let term = term {
            return AnyView(Text(term))
        }
        return AnyView(
            EquationPlaceholderView()
                .padding(settings.boxPadding)
                .frame(width: settings.boxSize, height: settings.boxSize)
        )
    }

    private var divider: some View {
        Rectangle().frame(height: 1)
    }
}


struct Equation_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            GeneralZeroOrderReactionEquationView(
                settings: EquationGeometrySettings(scale: 1),
                firstTerm: "k",
                numerator1: "Δc",
                denominator1: "Δt",
                numerator2Term1: "c2",
                numerator2Term2: "c1",
                denominator2Term1: "t2",
                denominator2Term2: "t1",
                emphasiseFractionTerm2: false
            )
            GeneralZeroOrderReactionEquationView(
                settings: EquationGeometrySettings(scale: 1),
                firstTerm: nil,
                numerator1: nil,
                denominator1: nil,
                numerator2Term1: nil,
                numerator2Term2: "0.5",
                denominator2Term1: nil,
                denominator2Term2: "10.12",
                emphasiseFractionTerm2: true
            )
            GeneralZeroOrderReactionEquationView(
                settings: EquationGeometrySettings(scale: 2),
                firstTerm: nil,
                numerator1: nil,
                denominator1: nil,
                numerator2Term1: nil,
                numerator2Term2: "0.5",
                denominator2Term1: nil,
                denominator2Term2: "10.12",
                emphasiseFractionTerm2: true
            )
        }
    }
}
