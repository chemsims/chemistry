//
// Reactions App
//

import XCTest
@testable import AcidsBases

class TitrationEquationDefinitionTests: XCTestCase {

    func testStrongBasePostEP() {
        let set = equationSet(.strongBasePostEP)
        let moles = TitrationEquation.molesToMolarity(
            moles: .init(.substance, isFilled: true),
            volume: .init(.substance, isFilled: true, formatter: .decimals()),
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

    func testWeakAcidPreEPBlank() {
        let set = equationSet(.weakAcidPreEPBlank)

        // Check left column
        let molesDiff = TitrationEquation.molesDifference(
            difference: .filled(.substance),
            subtracting: .blank(.titrant),
            from: .filled(.initialSubstance)
        )
        let pHPka = TitrationEquation.pKLog(
            pConcentration: .filled(
                .hydrogen,
                formatter: .decimals(places: 2)
            ),
            pK: .filled(.kA),
            numeratorConcentration: .filled(.secondary),
            denominatorConcentration: .filled(.substance)
        )
        compareEquations(
            set.left, [molesDiff, .filled(molesDiff), pHPka, .filled(pHPka)]
        )

        // Check right column
        let moles = TitrationEquation.molesToMolarity(
            moles: .blank(.titrant),
            volume: .blank(.titrant, formatter: .decimals(places: 3)),
            molarity: .blank(.titrant, formatter: .decimals(places: 2))
        )
        let substanceConcentration = TitrationEquation.concentrationToMolesOverVolume(
            concentration: .filled(.substance),
            moles: .filled(.substance),
            firstVolume: .filled(.initialSubstance, formatter: .decimals(places: 2)),
            secondVolume: .blank(.titrant, formatter: .decimals(places: 2))
        )
        let secondaryConcentration = TitrationEquation.concentrationToMolesOverVolume(
            concentration: .filled(.secondary),
            moles: .filled(.secondary),
            firstVolume: .filled(.initialSubstance, formatter: .decimals(places: 2)),
            secondVolume: .blank(.titrant, formatter: .decimals(places: 2))
        )

        compareEquations(
            set.right, [
                moles,
                .filled(moles),
                substanceConcentration,
                .filled(substanceConcentration),
                secondaryConcentration,
                .filled(secondaryConcentration)
            ]
        )
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
    static func filled(
        _ term: Term,
        formatter: EquationTermFormatter = .scientific()
    ) -> TitrationEquationTerm.Placeholder<Term> {
        .init(term, isFilled: true, formatter: formatter)
    }

    static func blank(
        _ term: Term,
        formatter: EquationTermFormatter = .scientific()
    ) -> TitrationEquationTerm.Placeholder<Term> {
        .init(term, isFilled: false, formatter: formatter)
    }
}
