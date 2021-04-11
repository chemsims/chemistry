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

    mutating func didPerform(action: SoluteParticleAction) {
        let nextCount = count(of: action) + 1
        guard nextCount <= maxAllowed else {
            return
        }
        counts[action] = nextCount
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

enum SoluteParticleAction: CaseIterable {
    case emitted,
         enteredWater,
         dissolved
}
