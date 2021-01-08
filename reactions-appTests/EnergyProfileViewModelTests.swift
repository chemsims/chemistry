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
}
