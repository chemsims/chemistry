//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct TitrationEquationView: View {

    typealias Term = TitrationEquationTerm

    let leftColumn: [TitrationEquation]
    let rightColumn: [TitrationEquation]

    var body: some View {
        Text("Hello, World!")
    }
}

struct TitrationEquationView_Previews: PreviewProvider {
    static var previews: some View {
        TitrationEquationView(
            leftColumn: [
                .kW(kA: .kA, kB: .kB)
            ],
            rightColumn: [
                .kToConcentration(kValue: .kA, firstNumeratorConcentration: .hydrogen, secondNumeratorConcentration: .hydroxide, denominatorConcentration: .hydrogen)
            ]
        )
    }
}
