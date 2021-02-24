//
// Reactions App
//

import Foundation

public class ScreenStateTreeNode<State: ScreenState> {

    public init(state: State) {
        self.state = state
    }

    public let state: State
    public var staticNext: ScreenStateTreeNode<State>? {
        didSet {
            staticNext?.staticPrev = self
        }
    }
    fileprivate var staticPrev: ScreenStateTreeNode<State>?

    public func next(model: State.Model) -> ScreenStateTreeNode<State>? {
        staticNext
    }

    public func prev(model: State.Model) -> ScreenStateTreeNode<State>? {
        staticPrev
    }
}

public class ConditionalScreenStateNode<State: ScreenState>: ScreenStateTreeNode<State> {
    public init(state: State, applyAlternativeNode: @escaping (State.Model) -> Bool) {
        self.applyAlternativeNode = applyAlternativeNode
        super.init(state: state)
    }

    private let applyAlternativeNode: (State.Model) -> Bool
    public var staticNextAlternative: ScreenStateTreeNode<State>? {
        didSet {
            staticNextAlternative?.staticPrev = self
        }
    }

    public override func next(model: State.Model) -> ScreenStateTreeNode<State>? {
        if applyAlternativeNode(model) {
            return staticNextAlternative
        }
        return staticNext
    }
}

extension ScreenStateTreeNode {
    public static func build<State: ScreenState>(states: [State]) -> ScreenStateTreeNode<State>? {
        let nodes = states.map { ScreenStateTreeNode<State>(state: $0) }

        (0..<nodes.count).forEach { index in
            let nextIndex = index + 1
            let nextNode = nodes.indices.contains(nextIndex) ? nodes[nextIndex] : nil
            nodes[index].staticNext = nextNode
        }

        return nodes.first
    }
}
