//
// Reactions App
//

import XCTest
@testable import reactions_equilibrium

class GaseousReactionViewModelPumpStatementTests: XCTestCase {

    func testBeakyStatementWhenPumpingAOrB() {
        let model = GaseousReactionViewModel()
        let nav = model.navigation!
        nav.nextUntil { $0.inputState == .addReactants }

        XCTAssertEqual(model.selectedPumpReactant, .A)

        func addMoreStatement(_ reactant: AqueousMoleculeReactant) -> String {
            "Add a bit more of \(reactant.rawValue)"
        }

        XCTAssertFalse(model.statement.content.starts(with: addMoreStatement(.A)))
        model.next()

        XCTAssert(model.statement.content.starts(with: addMoreStatement(.A)))

        while (model.componentWrapper.canIncrement(molecule: .A)) {
            model.pumpModel.onDownPump()
        }

        let saturatedAStatement = StatementUtil.hasAddedEnough(of: "A", complement: "B", canAddComplement: true)
        XCTAssertEqual(model.statement, saturatedAStatement)

        model.selectedPumpReactant = .B
        while(model.componentWrapper.canIncrement(molecule: .B)) {
            model.pumpModel.onDownPump()
        }

        let saturatedBStatement = StatementUtil.hasAddedEnough(of: "B", complement: "A", canAddComplement: false)
        XCTAssertEqual(model.statement, saturatedBStatement)
    }

}
