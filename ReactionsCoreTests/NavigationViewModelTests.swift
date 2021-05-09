//
// Reactions App
//

import XCTest
import ReactionsCore

class NavigationViewModelTests: XCTestCase {

    func testNextAppliesTheNextState() {
        let s1 = SetValueState(value: 1)
        let s2 = SetValueState(value: 2)
        let s3 = SetValueState(value: 3)
        let states = [s1, s2, s3]

        let tester = TesterClass()
        let model = NavigationModel(model: tester, states: states)

        XCTAssertEqual(tester.value, s1.value)

        model.next()
        XCTAssertEqual(tester.value, s2.value)

        model.next()
        XCTAssertEqual(tester.value, s3.value)

        model.next()
        XCTAssertEqual(tester.value, s3.value)
    }

    func testBackReAppliesThePreviousState() {
        let s1 = SetValueState(value: 1)
        let s2 = SetValueState(value: 2, shouldReapply: false)
        let s3 = SetValueState(value: 3)
        let states = [s1, s2, s3]

        let tester = TesterClass()
        let model = NavigationModel(model: tester, states: states)

        model.next()
        model.next()
        model.next()

        XCTAssertEqual(tester.value, s3.value)

        model.back()
        XCTAssertEqual(tester.value, s3.value)

        model.back()
        XCTAssertEqual(tester.value, s1.value)

        model.back()
        XCTAssertEqual(tester.value, s1.value)
    }

    func testTheNextStateIsAutomaticallyDispatched() {
        let expectation = self.expectation(description: "Set state to 2")
        let delay = 0.1
        let maxDelay = 1.35 * delay
        let minDelay = 0.65 * delay
        let s0 = SetValueState(value: 0)
        let s1 = StateWithAutoDispatch(value: 1, nextStateDelay: delay)
        let s2 = SetValueState(value: 2, expectation: expectation)

        let tester = TesterClass()
        let model = NavigationModel(model: tester, states: [s0, s1, s2])

        XCTAssertEqual(tester.value, s0.value)

        model.next()
        let t0 = DispatchTime.now()
        XCTAssertEqual(tester.value, s1.value)

        waitForExpectations(timeout: maxDelay, handler: nil)
        XCTAssertEqual(tester.value, s2.value)

        let t1 = DispatchTime.now()
        let elapsedNano = t1.uptimeNanoseconds - t0.uptimeNanoseconds
        let elapsedSeconds = Double(elapsedNano) / (1E9)

        XCTAssertGreaterThanOrEqual(elapsedSeconds, minDelay)
    }

    func testIgnoreOnBack() {
        let s1 = SetValueState(value: 1)
        let s2 = SetValueState(value: 2, ignoreOnBack: true)
        let s3 = SetValueState(value: 3)

        let tester = TesterClass()
        let model = NavigationModel(model: tester, states: [s1, s2, s3])

        model.next()
        model.next()
        XCTAssertEqual(tester.value, s3.value)

        model.back()
        XCTAssertEqual(tester.value, s1.value)

        model.next()
        XCTAssertEqual(tester.value, s2.value)
    }

    func testConditionalNavigation() {
        let s1 = SetValueState(value: 1)
        let s2 = SetValueState(value: 2, shouldReapply: false)
        let s3 = SetValueState(value: 3)
        let s3Alternative = SetValueState(value: 4)

        let s1Node = ScreenStateTreeNode(state: s1)
        let s2Node = ConditionalScreenStateNode(state: s2, applyAlternativeNode: { $0.value == 2 })
        let s3Node = ScreenStateTreeNode(state: s3)
        let s3AlternativeNode = ScreenStateTreeNode(state: s3Alternative)

        s1Node.staticNext = s2Node
        s2Node.staticNext = s3Node
        s2Node.staticNextAlternative = s3AlternativeNode

        let tester = TesterClass()
        let model = NavigationModel(model: tester, rootNode: s1Node)

        XCTAssertEqual(tester.value, s1.value)

        model.next()
        XCTAssertEqual(tester.value, s2.value)

        model.next()
        XCTAssertEqual(tester.value, s3Alternative.value)

        model.back()
        XCTAssertEqual(tester.value, s3Alternative.value)

        model.next()
        XCTAssertEqual(tester.value, s3.value)
    }
}

private class TesterClass { var value = 0 }

private class TesterState: ScreenState, SubState {
    func delayedStates(model: TesterClass) -> [DelayedState<TesterState>] {
        []
    }
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

private class SetValueState: TesterState {
    init(
        value: Int,
        shouldReapply: Bool = true,
        expectation: XCTestExpectation? = nil,
        ignoreOnBack: Bool = false
    ) {
        self.value = value
        self.shouldReapply = shouldReapply
        self.expectation = expectation
        self.doIgnoreOnBack = ignoreOnBack
    }

    let value: Int
    let shouldReapply: Bool
    let expectation: XCTestExpectation?
    let doIgnoreOnBack: Bool

    override func apply(on model: TesterClass) {
        model.value = value
        if let e = expectation {
            e.fulfill()
        }
    }

    override func reapply(on model: TesterClass) {
        if shouldReapply {
            apply(on: model)
        }
    }

    override var ignoreOnBack: Bool {
        doIgnoreOnBack
    }

}

private class StateWithAutoDispatch: SetValueState {
    init(value: Int, nextStateDelay: Double) {
        self.nextStateDelay = nextStateDelay
        super.init(value: value)
    }

    let nextStateDelay: Double

    override func nextStateAutoDispatchDelay(model: TesterClass) -> Double? {
        nextStateDelay
    }
}
