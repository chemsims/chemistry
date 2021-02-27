//
// Reactions App
//


import SwiftUI

struct AqueousEquationView: View {

    let equations: BalancedReactionEquations

    var body: some View {
        QuotientDefinitionView(coefficients: equations.coefficients)
    }
}

private struct QuotientDefinitionView: View {

    let coefficients: BalancedReactionCoefficients

    var body: some View {
        HStack(spacing: 2) {
            Text("Q")
        }
    }
}

struct AqueousEquationView_Previews: PreviewProvider {
    static var previews: some View {
        AqueousEquationView(
            equations: BalancedReactionEquations(
                coefficients: BalancedReactionCoefficients(
                    reactantACoefficient: 2,
                    reactantBCoefficient: 1,
                    productCCoefficient: 1,
                    productDCoefficient: 4
                ),
                a0: 0.5,
                b0: 0.4,
                finalTime: 20
            )
        )
    }
}
