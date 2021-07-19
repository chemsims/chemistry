//
// Reactions App
//

import SwiftUI

/// Adds an accessibility action to run a closure using an integer input twice.
public struct BeakerAccessibilityAddMultipleCountActions: ViewModifier {

    public init(
        actionName: @escaping (Int) -> String,
        doAdd: @escaping (Int) -> Void,
        firstCount: Int,
        secondCount: Int
    ) {
        self.actionName = actionName
        self.doAdd = doAdd
        self.firstCount = firstCount
        self.secondCount = secondCount
    }

    let actionName: (Int) -> String
    let doAdd: (Int) -> Void
    let firstCount: Int
    let secondCount: Int

    public func body(content: Content) -> some View {
        content
            .modifier(modifier(firstCount))
            .modifier(modifier(secondCount))
    }

    private func modifier(_ count: Int) -> some ViewModifier {
        BeakerAccessibilityAddSingleCountActions(
            actionName: actionName(count),
            doAdd: { doAdd(count) }
        )
    }
}

private struct BeakerAccessibilityAddSingleCountActions: ViewModifier {

    let actionName: String
    let doAdd: () -> Void

    func body(content: Content) -> some View {
        content.accessibilityAction(named: Text(actionName)) {
            doAdd()
        }
    }
}
