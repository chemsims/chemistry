//
// Reactions App
//
  

import SwiftUI


struct GeneralZeroOrderReactionEquationView: View {

    let firstTerm: String?
    let numerator1: String?
    let denominator1: String?

    let numerator2Term1: String?
    let numerator2Term2: String

    let denominator2Term1: String?
    let denominator2Term2: String

    let emphasiseFractionTerm2: Bool

    private let boxSize: CGFloat = 30
    private let negativeWidth: CGFloat = 10

    var body: some View {
        HStack {
            Text("Rate")
            Text("=")
            termOrBox(firstTerm)
                .frame(width: boxSize, height: boxSize)

            Text("=")

            fraction1

            Text("=")

            fraction2
        }
    }

    private var fraction1: some View {
        VStack(spacing: 0) {
            HStack(spacing: 1) {
                Text("-")
                    .frame(width: negativeWidth)
                termOrBox(numerator1)
                    .frame(width: boxSize)
                Text("")
                    .frame(width: negativeWidth)
            }
            divider
                .frame(width: boxSize + 5)

            HStack(spacing: 1) {
                Text("")
                    .frame(width: negativeWidth)
                termOrBox(denominator1)
                    .frame(width: boxSize)
                Text("")
                    .frame(width: negativeWidth)
            }

        }.frame(width: 50)
    }

    private var fraction2: some View {
        VStack(spacing: 1) {
            fraction2Part(term1: numerator2Term1, term2: numerator2Term2, isNegative: true)
            divider
                .frame(width: 80)
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

            termOrBox(term1)
                .frame(width: boxSize)

            Text("–")

            Text(term2)
                .frame(width: boxSize)
                .foregroundColor(emphasiseFractionTerm2 ? .orangeAccent : .black)

            Text(")")

            Text("")
                .frame(width: negativeWidth)
        }
    }


    private func termOrBox(_ term: String?) -> some View {
        if let term = term {
            return AnyView(Text(term))
        }
        return AnyView(EquationPlaceholderView2().padding(4).frame(height: boxSize))
    }

    private var divider: some View {
        Rectangle().frame(height: 1)
    }
}

struct EquationPlaceholderView2: View {

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
                firstTerm: nil,
                numerator1: nil,
                denominator1: nil,
                numerator2Term1: nil,
                numerator2Term2: "0.5",
                denominator2Term1: nil,
                denominator2Term2: "6.6",
                emphasiseFractionTerm2: true
            )
        }
    }
}
