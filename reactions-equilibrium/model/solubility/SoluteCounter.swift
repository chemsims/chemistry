//
// Reactions App
//

import CoreGraphics

struct SoluteCounter {
    var maxAllowed: Int

    init(maxAllowed: Int) {
        self.maxAllowed = maxAllowed
    }

    private var counts = [SoluteParticleAction:Int]()

    /// Increments the count of `action`, while also incrementing any actions which should occur before
    /// the provided `action`, to ensure the counts are consistent
    ///
    /// For example, when performing an entered water action, the function will ensure that the emitted
    /// action is at the same count
    mutating func didPerform(action: SoluteParticleAction) {
        let nextCount = count(of: action) + 1
        guard nextCount <= maxAllowed else {
            return
        }
        counts[action] = nextCount

        let precedingActions = SoluteParticleAction.allCases.filter { $0 < action }
        precedingActions.forEach { precedingAction in
            if count(of: precedingAction) < nextCount {
                counts[precedingAction] = nextCount
            }
        }
    }

    mutating func reset() {
        counts.removeAll()
    }

    func count(of action: SoluteParticleAction) -> Int {
        counts[action] ?? 0
    }

    func canPerform(action: SoluteParticleAction) -> Bool {
        (count(of: action)) < maxAllowed
    }

    func fraction(of action: SoluteParticleAction) -> CGFloat {
        CGFloat(count(of: action)) / CGFloat(maxAllowed)
    }
}

enum SoluteParticleAction: Comparable, CaseIterable {
    case emitted,
         enteredWater,
         dissolved
}
