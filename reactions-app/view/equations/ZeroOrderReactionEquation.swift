//
// Reactions App
//
  

import SwiftUI

struct ZeroOrderEquationFilled: View {

    /// Scales the view
    let scale: CGFloat

    var body: some View {
        GeneralZeroOrderReactionEquationView(
            scale: scale,
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
            scale: scale,
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

    let scale: CGFloat

    let firstTerm: String?
    let numerator1: String?
    let denominator1: String?

    let numerator2Term1: String?
    let numerator2Term2: String

    let denominator2Term1: String?
    let denominator2Term2: String

    let emphasiseFractionTerm2: Bool

    private var boxSize: CGFloat {
        35 * scale
    }
    private var boxPadding: CGFloat {
        6 * scale
    }
    private var negativeWidth: CGFloat {
        10 * scale
    }
    private var parenWidth: CGFloat {
        7 * scale
    }
    private var fontSize: CGFloat {
        15 * scale
    }

    private var fraction1DividerWidth: CGFloat {
        30 * scale
    }
    private var fraction2DividerWidth: CGFloat {
        90 * scale
    }

    var body: some View {
        HStack {
            Text("Rate")
            Text("=")
            termOrBox(firstTerm)
                .frame(minWidth: boxSize)

            Text("=")

            fraction1

            Text("=")

            fraction2
        }.font(.system(size: fontSize))
    }

    private var fraction1: some View {
        VStack(spacing: 0) {
            HStack(spacing: 1) {
                Text("–")
                    .frame(width: negativeWidth)
                termOrBox(numerator1)
                    .frame(minWidth: boxSize)
                Text("")
                    .frame(width: negativeWidth)
            }
            divider
                .frame(width: fraction1DividerWidth)

            HStack(spacing: 1) {
                Text("")
                    .frame(width: negativeWidth)
                termOrBox(denominator1)
                    .frame(minWidth: boxSize)
                Text("")
                    .frame(width: negativeWidth)
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
                .frame(width: negativeWidth)

            Text("(")
                .frame(width: parenWidth)

            termOrBox(term1)
                .frame(minWidth: boxSize)

            Text("–")
                .frame(width: negativeWidth)

            Text(term2)
                .frame(minWidth: boxSize)
                .foregroundColor(emphasiseFractionTerm2 ? .orangeAccent : .black)

            Text(")")
                .frame(width: parenWidth)

            Text("")
                .frame(width: negativeWidth)
        }
    }

    private func termOrBox(_ term: String?) -> some View {
        if let term = term {
            return AnyView(Text(term))
        }
        return AnyView(
            EquationPlaceholderView()
                .padding(boxPadding)
                .frame(width: boxSize, height: boxSize)
        )
    }

    private var divider: some View {
        Rectangle().frame(height: 1)
    }
}

struct EquationPlaceholderView: View {

    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .stroke(style: StrokeStyle(
                            lineWidth: 1,
                            lineCap: .square,
                            lineJoin: .round,
                            miterLimit: 0,
                            dash: dash(geometry),
                            dashPhase: dashPhase(geometry)
                        )
                )
        }
    }

    private func dash(_ geometry: GeometryProxy) -> [CGFloat] {
        let phase = dashPhase(geometry)
        return [2 * phase, phase]
    }

    private func dashPhase(_ geometry: GeometryProxy) -> CGFloat {
        geometry.size.width / 6
    }
}


struct Equation_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            GeneralZeroOrderReactionEquationView(
                scale: 1,
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
                scale: 2,
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
