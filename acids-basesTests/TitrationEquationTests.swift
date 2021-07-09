//
// Reactions App
//

import XCTest
@testable import acids_bases

class TitrationEquationTests: XCTestCase {

    func testStrongSubstancePostEP() {
        let set = equationSet(.strongBasePostEP)
        let moles = TitrationEquation.molesToMolarity(
            moles: .init(.substance, isFilled: true),
            volume: .init(.substance, isFilled: true),
            molarity: .init(.substance, isFilled: true
            )
        )
        let concentration = TitrationEquation.concentrationToMolesDifferenceOverVolume(
            concentration: .filled(.hydrogen),
            subtractingMoles: .filled(.substance),
            fromMoles: .filled(.titrant),
            firstVolume: .filled(.substance),
            secondVolume: .filled(.titrant)
        )

        compareEquations(set.left, [moles, .filled(moles), concentration, .filled(concentration)])
    }

    // Compares each equation individually, since failures are hard to read when
    // when comparing the whole array
    private func compareEquations(
        _ equations: [TitrationEquation],
        _ expected: [TitrationEquation]
    ) {
        XCTAssertEqual(equations.count, expected.count)
        for i in equations.indices {
            XCTAssertEqual(equations[i], expected[i])
        }
    }

    private func equationSet(_ state: TitrationViewModel.EquationState) -> TitrationEquationSet {
        state.equationSet
    }
}

private extension TitrationEquationTerm.Placeholder {
    static func filled(_ term: Term) -> TitrationEquationTerm.Placeholder<Term> {
        .init(term, isFilled: true)
    }
}
