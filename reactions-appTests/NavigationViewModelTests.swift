//
// Reactions App
//
  

import XCTest
@testable import reactions_app

class NavigationViewModelTests: XCTestCase {

    func testNextAppliesTheNextState() {
        let s1 = SetValueState(value: 1)
        let s2 = SetValueState(value: 2)
        let s3 = SetValueState(value: 3)
        let states = [s1, s2, s3]

        let tester = TesterClass()
        let model = NavigationViewModel(model: tester, states: states)

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
        let model = NavigationViewModel(model: tester, states: states)

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
        let s0 = SetValueState(value: 0)
        let s1 = StateWithAutoDispatch(value: 1, nextStateDelay: delay)
        let s2 = SetValueState(value: 2, expectation: expectation)

        let tester = TesterClass()
        let model = NavigationViewModel(model: tester, states: [s0, s1, s2])

        XCTAssertEqual(tester.value, s0.value)

        model.next()
        let t0 = DispatchTime.now()
        XCTAssertEqual(tester.value, s1.value)

        waitForExpectations(timeout: 1.1 * delay, handler: nil)
        XCTAssertEqual(tester.value, s2.value)

        let t1 = DispatchTime.now()
        let elapsedNano = t1.uptimeNanoseconds - t0.uptimeNanoseconds
        let elapsedSeconds = Double(elapsedNano) / (1E9)

        XCTAssertGreaterThanOrEqual(elapsedSeconds, 0.9 * delay)
    }
}

fileprivate class TesterClass { var value = 0 }

fileprivate class TesterState: ScreenState, SubState {
    var delayedStates: [DelayedState<TesterState>] = []
    func apply(on model: TesterClass) { }

    func unapply(on model: TesterClass) { }

    func reapply(on model: TesterClass) { }

    func nextStateAutoDispatchDelay(model: TesterClass) -> Double? {
        nil
    }

    typealias NestedState = TesterState
    typealias Model = TesterClass
}

fileprivate class SetValueState: TesterState {
    init(value: Int, shouldReapply: Bool = true, expectation: XCTestExpectation? = nil) {
        self.value = value
        self.shouldReapply = shouldReapply
        self.expectation = expectation
    }

    let value: Int
    let shouldReapply: Bool
    let expectation: XCTestExpectation?

    override func apply(on model: TesterClass) {
        model.value = value
        if let e = expectation {
            e.fulfill()
        }
    }

    override func reapply(on model: TesterClass) {
        if (shouldReapply) {
            apply(on: model)
        }
    }
}

fileprivate class StateWithAutoDispatch: SetValueState {
    init(value: Int, nextStateDelay: Double) {
        self.nextStateDelay = nextStateDelay
        super.init(value: value)
    }

    let nextStateDelay: Double

    override func nextStateAutoDispatchDelay(model: TesterClass) -> Double? {
        nextStateDelay
    }
}
