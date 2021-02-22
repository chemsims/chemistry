//
// Reactions App
//

import XCTest
@testable import reactions_app

class ScreenStateTreeNodeTests: XCTestCase {

    func testBuildingLinearStateTree() {
        let s1 = TesterState(value: 1)
        let s2 = TesterState(value: 2)
        let s3 = TesterState(value: 3)
        let s1Node = ScreenStateTreeNode<TesterState>.build(states: [s1, s2, s3])

        XCTAssertNotNil(s1Node)
        XCTAssertEqual(s1Node!.state.value, s1.value)
        XCTAssertNil(s1Node!.prev(model: TesterClass()))

        let s2Node = s1Node?.next(model: TesterClass())
        XCTAssertNotNil(s2Node)
        XCTAssertEqual(s2Node!.state.value, s2.value)
        XCTAssertEqual(s2Node!.prev(model: TesterClass())?.state.value, s1.value)

        let s3Node = s2Node?.next(model: TesterClass())
        XCTAssertNotNil(s3Node)
        XCTAssertEqual(s3Node!.state.value, s3.value)
        XCTAssertEqual(s3Node!.prev(model: TesterClass())?.state.value, s2.value)
        XCTAssertNil(s3Node?.next(model: TesterClass()))
    }
}

private class TesterClass { var value = 0 }
private class TesterState: ScreenState, SubState {

    let value: Int
    init(value: Int) {
        self.value = value
    }

    var delayedStates: [DelayedState<TesterState>] = []
    func apply(on model: TesterClass) { }

    func unapply(on model: TesterClass) { }

    func reapply(on model: TesterClass) { }

    func nextStateAutoDispatchDelay(model: TesterClass) -> Double? {
        nil
    }

    var ignoreOnBack: Bool {
        false
    }

    typealias NestedState = TesterState
    typealias Model = TesterClass
}
