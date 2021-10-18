//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import ChemicalReactions

class PrecipitationScreenNavigationTests: XCTestCase {

    func testParametersAreReapplied() {
        doTest(\.statement)
        doTest(\.input)
        doTest(\.equationState)
        doTest(\.highlightedElements)
        doTest(\.showUnknownMetal)
    }

    private func doTest<T: Equatable>(_ path: KeyPath<PrecipitationScreenViewModel, T>) {
        let model = PrecipitationScreenViewModel(persistence: PrecipitationInputPersistence())
        checkPreviousValueIsReapplied(
            model: model,
            navigation: model.navigation!,
            prevValueKeyPath: path,
            runOnEachStep: { addReactantIfNeeded(to: model) }
        )
    }

    private func addReactantIfNeeded(to model: PrecipitationScreenViewModel) {
        switch model.input {
        case let .addReactant(type):
            while(!model.components.hasAddedEnough(of: type)) {
                model.components.add(reactant: type, count: 1)
            }
        default:
            break
        }
    }
    
}

private extension PrecipitationScreenViewModel {
    var highlightedElements: [ScreenElement] {
        highlights.elements
    }
}
