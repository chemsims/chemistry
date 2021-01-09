//
// Reactions App
//
  

import XCTest
@testable import reactions_app

class EnergyProfileViewModelTests: XCTestCase {

    func testCatalystsAreUsedUp() {
        let model = EnergyProfileViewModel()
        XCTAssertEqual(model.availableCatalysts, Catalyst.allCases)

        model.catalystState = .selected(catalyst: .A)
        model.saveCatalyst()
        XCTAssertEqual(model.availableCatalysts, [.B, .C])

        model.catalystState = .selected(catalyst: .B)
        model.saveCatalyst()
        XCTAssertEqual(model.availableCatalysts, [.C])

        model.catalystState = .selected(catalyst: .C)
        model.saveCatalyst()
        XCTAssertEqual(model.availableCatalysts, [])

        model.removeCatalystFromStack()
        XCTAssertEqual(model.availableCatalysts, [.C])

        model.removeCatalystFromStack()
        XCTAssertEqual(model.availableCatalysts, [.B, .C])

        model.removeCatalystFromStack()
        XCTAssertEqual(model.availableCatalysts, [.A, .B, .C])
    }

    func testNavigationCompletesWithoutError() {
        let model = EnergyProfileViewModel()
        let navigation = EnergyProfileNavigationViewModel.model(model)

        var didFinish = false
        var didGetBackToStart = false
        func nextScreen() {
            didFinish = true
        }

        func prevScreen() {
            didGetBackToStart = true
        }
        navigation.nextScreen = nextScreen
        navigation.prevScreen = prevScreen

        while (!didFinish) {
            navigation.next()
        }
        XCTAssertEqual(model.availableCatalysts, [])

        while (!didGetBackToStart) {
            navigation.back()
        }
        XCTAssertEqual(model.availableCatalysts, Catalyst.allCases)

        didFinish = false
        while(!didFinish) {
            navigation.next()
        }
    }

    func testNavigationCatalystStates() {
        let model = EnergyProfileViewModel()
        let navigation = EnergyProfileNavigationViewModel.model(model)
        navigation.nextScreen = { XCTFail("Reached final screen") }
        navigation.prevScreen = { XCTFail("Reached first screen") }

        func runForwardFromFirstActiveState() {
            navigation.back()
            XCTAssertEqual(model.catalystState, .visible)
            navigation.next()

            // They are now active - can be clicked
            XCTAssertEqual(model.catalystState, .active)
            XCTAssertEqual(model.particleState, .none)

            // A is primed
            navigation.next()
            XCTAssertEqual(model.catalystState, .pending(catalyst: .A))
            XCTAssertEqual(model.particleState, .none)

            // A starts shaking
            navigation.next()
            XCTAssertEqual(model.particleState, .fallFromContainer)
            XCTAssertEqual(model.catalystInBeaker, .A)

            // A stops shaking
            navigation.next()
            XCTAssertEqual(model.catalystState, .selected(catalyst: .A))
            XCTAssertEqual(model.particleState, .fallFromContainer)

            while (model.reactionState != .completed) {
                navigation.next()
            }
            // First reaction has ended
            XCTAssertEqual(model.reactionState, .completed)
            XCTAssertEqual(model.catalystState, .active)
            XCTAssertEqual(model.usedCatalysts, [.A])
            XCTAssertEqual(model.particleState, .fallFromContainer)

            // Prepare a new catalyst (B)
            navigation.next()
            XCTAssertEqual(model.reactionState, .pending)
            XCTAssertEqual(model.catalystState, .pending(catalyst: .B))
            XCTAssertEqual(model.particleState, .none)

            // B starts shaking
            navigation.next()
            XCTAssertEqual(model.particleState, .fallFromContainer)
            XCTAssertEqual(model.catalystInBeaker, .B)

            // B stops shaking
            navigation.next()
            XCTAssertEqual(model.catalystState, .selected(catalyst: .B))
            XCTAssertEqual(model.particleState, .fallFromContainer)

            while (model.reactionState != .completed) {
                navigation.next()
            }

            // Second reaction has ended
            XCTAssertEqual(model.reactionState, .completed)
            XCTAssertEqual(model.catalystState, .active)
            XCTAssertEqual(model.usedCatalysts, [.A, .B])
            XCTAssertEqual(model.particleState, .fallFromContainer)

            // Prepare a new catalyst (C)
            navigation.next()
            XCTAssertEqual(model.reactionState, .pending)
            XCTAssertEqual(model.catalystState, .pending(catalyst: .C))
            XCTAssertEqual(model.particleState, .none)

            // C starts shaking
            navigation.next()
            XCTAssertEqual(model.particleState, .fallFromContainer)
            XCTAssertEqual(model.catalystInBeaker, .C)

            // C stops shaking
            navigation.next()
            XCTAssertEqual(model.catalystState, .selected(catalyst: .C))
            XCTAssertEqual(model.particleState, .fallFromContainer)

            // Last reaction has ended
            while (model.reactionState != .completed) {
                navigation.next()
            }
            XCTAssertEqual(model.reactionState, .completed)
            XCTAssertEqual(model.catalystState, .selected(catalyst: .C))
            XCTAssertEqual(model.usedCatalysts, [.A, .B, .C])
        }

        func runBackToFirstActiveState() {
            navigation.back()
            XCTAssertEqual(model.reactionState, .running)

            // Back to end of 2nd reaction
            while (model.reactionState != .completed) {
                navigation.back()
            }
            XCTAssertEqual(model.reactionState, .completed)
            XCTAssertEqual(model.catalystState, .active)
            XCTAssertEqual(model.particleState, .appearInBeaker)
            XCTAssertEqual(model.usedCatalysts, [.A, .B])
            XCTAssertEqual(model.catalystInBeaker, .B)

            navigation.back()
            XCTAssertEqual(model.reactionState, .running)
            XCTAssertEqual(model.catalystState, .selected(catalyst: .B))
            XCTAssertEqual(model.particleState, .appearInBeaker)

            // Back to end of 1st reaction
            while (model.reactionState != .completed) {
                navigation.back()
            }
            XCTAssertEqual(model.reactionState, .completed)
            XCTAssertEqual(model.catalystState, .active)
            XCTAssertEqual(model.particleState, .appearInBeaker)
            XCTAssertEqual(model.usedCatalysts, [.A])
            XCTAssertEqual(model.catalystInBeaker, .A)

            navigation.back()
            XCTAssertEqual(model.reactionState, .running)
            XCTAssertEqual(model.catalystState, .selected(catalyst: .A))
            XCTAssertEqual(model.particleState, .appearInBeaker)
            XCTAssertEqual(model.catalystColor, Catalyst.A.color)

            while (model.catalystState != .active) {
                navigation.back()
            }
            XCTAssertEqual(model.reactionState, .pending)
            XCTAssertEqual(model.catalystState, .active)
            XCTAssertEqual(model.availableCatalysts, [.A, .B, .C])
        }

        while (model.catalystState != .active) {
            navigation.next()
        }
        runForwardFromFirstActiveState()
        runBackToFirstActiveState()
        runForwardFromFirstActiveState()
        runBackToFirstActiveState()
    }

    private func testForwardFromActiveState(
        model: EnergyProfileViewModel,
        navigation: NavigationViewModel<EnergyProfileState>
    ) {

    }
}
