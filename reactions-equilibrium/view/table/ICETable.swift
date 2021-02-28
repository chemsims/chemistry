//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct ICETable: View {

    let equations: BalancedReactionEquations

    var body: some View {
        GeometryReader { geo in
            SizedICETable(
                width: geo.size.width,
                height: geo.size.height,
                equations: equations
            )
        }
    }
}

private struct SizedICETable: View {

    let width: CGFloat
    let height: CGFloat
    let equations: BalancedReactionEquations

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                cell("ICE")
                cell("Initial")
                cell("Change")
                cell("Final")
            }
            column(equation: equations.reactantA, name: "A")
            column(equation: equations.reactantB, name: "B")
            column(equation: equations.productC, name: "C")
            column(equation: equations.productD, name: "D")
        }
        .font(.system(size: 0.05 * width))
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }

    private func column(equation: Equation, name: String) -> some View {
        let change = equation.delta(t2: equations.convergenceTime)
        let changeSign = change > 0 ? "+" : ""
        let changeString = "\(changeSign)\(change.str(decimals: 2))"

        return VStack(spacing: 0) {
            cell(name)
            cell(equation, time: 0)
            cell(changeString, emphasise: true)
            cell(equation, time: equations.convergenceTime, emphasise: true)
        }
    }

    private func cell(_ equation: Equation, time: CGFloat, emphasise: Bool = false) -> some View {
        cell("\(equation.getY(at: time).str(decimals: 2))", emphasise: emphasise)
    }

    private func cell(_ text: String, emphasise: Bool = false) -> some View {
        Text(text)
            .frame(width: width / 5, height: height / 4)
            .foregroundColor(emphasise ? .orangeAccent : .black)
            .background(
                Rectangle()
                    .stroke()
            )
    }
}

extension Equation {
    fileprivate func delta(t2: CGFloat) -> CGFloat {
        getY(at: t2) - getY(at: 0)
    }
}

struct ICETable_Previews: PreviewProvider {
    static var previews: some View {
        ICETable(
            equations: BalancedReactionEquations(
                coefficients: BalancedReactionCoefficients(
                    reactantA: 2,
                    reactantB: 2,
                    productC: 1,
                    productD: 4
                ),
                a0: 0.4,
                b0: 0.5,
                finalTime: 15
            )
        )
        .padding()
    }
}
