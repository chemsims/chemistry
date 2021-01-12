//
// Reactions App
//
  

import Foundation

class ScreenStateTreeNode<State: ScreenState> {

    init(state: State) {
        self.state = state
    }

    let state: State
    var staticNext: ScreenStateTreeNode<State>? {
        didSet {
            staticNext?.staticPrev = self
        }
    }
    fileprivate var staticPrev: ScreenStateTreeNode<State>?

    func next(model: State.Model) -> ScreenStateTreeNode<State>? {
        staticNext
    }

    func prev(model: State.Model) -> ScreenStateTreeNode<State>? {
        staticPrev
    }
}

class ConditionalScreenStateNode<State: ScreenState>: ScreenStateTreeNode<State> {
    init(state: State, applyAlternativeNode: @escaping (State.Model) -> Bool) {
        self.applyAlternativeNode = applyAlternativeNode
        super.init(state: state)
    }

    private let applyAlternativeNode: (State.Model) -> Bool
    var staticNextAlternative: ScreenStateTreeNode<State>? {
        didSet {
            staticNextAlternative?.staticPrev = self
        }
    }

    override func next(model: State.Model) -> ScreenStateTreeNode<State>? {
        if (applyAlternativeNode(model)) {
            return staticNextAlternative
        }
        return staticNext
    }
}

extension ScreenStateTreeNode {
    static func build<State: ScreenState>(states: [State]) -> ScreenStateTreeNode<State>? {
        let nodes = states.map { ScreenStateTreeNode<State>(state: $0) }

        (0..<nodes.count).forEach { index in
            let nextIndex = index + 1
            let nextNode = nodes.indices.contains(nextIndex) ? nodes[nextIndex] : nil
            nodes[index].staticNext = nextNode
        }

        return nodes.first
    }
}
