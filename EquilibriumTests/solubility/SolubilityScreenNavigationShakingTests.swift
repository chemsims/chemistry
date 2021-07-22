//
// Reactions App
//

import XCTest
@testable import Equilibrium

class SolubilityScreenNavigationShakingTests: XCTestCase {

    func testFirstAddSolute() {
        let model = SolubilityViewModel(persistence: InMemorySolubilityPersistence())
        let nav = model.navigation!

        nav.nextUntil { $0.inputState == .addSolute(type: .primary) }
        assertSolute(model, .primary)
        assertShaking(model)

        nav.next()
        assertSolute(model, nil)
        assertNotShaking(model)

        nav.back()
        assertSolute(model, .primary)
        assertShaking(model)

        nav.back()
        assertSolute(model, nil)
        assertNotShaking(model)
    }

    func testFirstAddSaturatedSolute() {
        let model = SolubilityViewModel(persistence: InMemorySolubilityPersistence())
        let nav = model.navigation!

        nav.nextUntil { $0.inputState == .addSaturatedSolute }
        assertSolute(model, .primary)
        assertShaking(model)

        nav.next()
        assertSolute(model, nil)
        assertNotShaking(model)

        nav.back()
        assertSolute(model, .primary)
        assertShaking(model)

        nav.back()
        assertSolute(model, nil)
        assertNotShaking(model)
    }

    func testAddCommonIonSolute() {
        let model = SolubilityViewModel(persistence: InMemorySolubilityPersistence())
        let nav = model.navigation!

        nav.nextUntil { $0.inputState == .addSolute(type: .commonIon) }
        assertSolute(model, .commonIon)
        assertShaking(model)

        nav.next()
        assertSolute(model, .primary)
        assertShaking(model)
        XCTAssertEqual(model.inputState, .addSolute(type: .primary))

        nav.back()
        assertSolute(model, .commonIon)
        assertShaking(model)

        nav.back()
        assertSolute(model, nil)
        assertNotShaking(model)
    }

    func testFirstCommonIonAddSaturatedSolute() {
        let model = SolubilityViewModel(persistence: InMemorySolubilityPersistence())
        let nav = model.navigation!

        nav.nextUntil { $0.inputState == .addSaturatedSolute }
        nav.nextUntil { $0.inputState == .addSaturatedSolute }

        assertSolute(model, .primary)
        assertShaking(model)

        nav.next()
        assertSolute(model, nil)
        assertNotShaking(model)

        nav.back()
        assertSolute(model, .primary)
        assertShaking(model)

        nav.back()
        assertSolute(model, nil)
        assertNotShaking(model)
    }

    func testAddAcidSolute() {
        let model = SolubilityViewModel(persistence: InMemorySolubilityPersistence())
        let nav = model.navigation!

        nav.nextUntil { $0.inputState == .addSolute(type: .acid) }

        assertSolute(model, .acid)
        assertShaking(model)

        nav.next()
        assertSolute(model, nil)
        assertNotShaking(model)

        nav.back()
        assertSolute(model, .acid)
        assertShaking(model)

        nav.back()
        assertSolute(model, nil)
        assertNotShaking(model)
    }

    private func assertSolute(_ model: SolubilityViewModel, _ solute: SoluteType?) {
        XCTAssertEqual(model.activeSolute.value, solute)
    }

    private func assertShaking(_ model: SolubilityViewModel) {
        assertShake(true, model)
    }

    private func assertNotShaking(_ model: SolubilityViewModel) {
        assertShake(false, model)
    }

    private func assertShake(_ value: Bool, _ model: SolubilityViewModel) {
        XCTAssertEqual(model.shakingModel.shake.position.isUpdating, value)
    }
}
