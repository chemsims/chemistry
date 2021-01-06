//
// Reactions App
//
  

import Foundation

class ScreenStateTreeNode<State: ScreenState> {

    init(state: State) {
        self.state = state
    }

    let state: State
    var staticNext: ScreenStateTreeNode<State>?
    var staticPrev: ScreenStateTreeNode<State>?

    func next(model: State.Model) -> ScreenStateTreeNode<State>? {
        staticNext
    }

    func prev(model: State.Model) -> ScreenStateTreeNode<State>? {
        staticPrev
    }
}

extension ScreenStateTreeNode {
    static func build<State: ScreenState>(states: [State]) -> ScreenStateTreeNode<State>? {
        let nodes = states.map { ScreenStateTreeNode<State>(state: $0) }

        (0..<nodes.count).forEach { index in
            let prevIndex = index - 1
            let nextIndex = index + 1

            let prevNode = nodes.indices.contains(prevIndex) ? nodes[prevIndex] : nil
            let nextNode = nodes.indices.contains(nextIndex) ? nodes[nextIndex] : nil
            nodes[index].staticPrev = prevNode
            nodes[index].staticNext = nextNode
        }

        return nodes.first
    }
}
