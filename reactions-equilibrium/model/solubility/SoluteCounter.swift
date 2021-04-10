//
// Reactions App
//

import CoreGraphics

struct SoluteCounter {
    var maxAllowed: Int

    init(maxAllowed: Int) {
        self.maxAllowed = maxAllowed
        self.counts = Dictionary(
            uniqueKeysWithValues: SoluteParticleAction.allCases.map {
                ($0, 0)
            }
        )
    }

    private var counts = [SoluteParticleAction:Int]()

    mutating func didPerform(action: SoluteParticleAction) {
        let count = counts[action] ?? -1
        counts[action] = count + 1
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
