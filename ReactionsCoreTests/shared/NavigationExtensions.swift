//
// Reactions App
//

import XCTest
import ReactionsCore

extension NavigationModel {

    func nextWhile(_ condition: (State.Model) -> Bool) {
        progressWhile(condition, isNext: true)
    }

    func backWhile(_ condition: (State.Model) -> Bool) {
        progressWhile(condition, isNext: false)
    }

    private func progressWhile(_ condition: (State.Model) -> Bool, isNext: Bool) {
        var didReachEnd = false
        let end = {
            didReachEnd = true
            XCTFail("Reached limit of navigation state before condition was met")
        }
        if isNext {
            nextScreen = end
        } else {
            prevScreen = end
        }
        while condition(model) && !didReachEnd {
            isNext ? next() : back()
        }
    }

    func nextWhile(_ keyPath: KeyPath<State.Model, Bool>) {
        nextWhile { $0[keyPath: keyPath] }
    }

    func nextUntil(_ condition: (State.Model) -> Bool) {
        nextWhile { !condition($0) }
    }

    func nextUntil(
        _ keyPath: KeyPath<State.Model, Bool>,
        withAction: (State.Model) -> Void
    ) {
        nextUntil { $0[keyPath: keyPath] }
    }

    func backWhile(_ keyPath: KeyPath<State.Model, Bool>) {
        backWhile { $0[keyPath: keyPath] }
    }

    func backUntil(_ condition: (State.Model) -> Bool) {
        backWhile { !condition($0) }
    }

    func backUntil(_ keyPath: KeyPath<State.Model, Bool>) {
        backUntil { $0[keyPath: keyPath] }
    }
}

extension NavigationModel where State.Model: HasStatement {
    func nextUntilStatement(startsWith startOfString: String) {
        nextUntil {
            $0.statement.content.lowercased().starts(with: startOfString.lowercased())
        }
    }
}

protocol HasStatement {
    var statement: [TextLine] { get }
}

extension Array where Element == TextLine {
    var content: String {
        self.reduce("") { $0 + $1.asString }
    }
}
