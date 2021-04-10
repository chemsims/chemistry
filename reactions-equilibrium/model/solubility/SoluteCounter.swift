//
// Reactions App
//

import CoreGraphics

struct SoluteCounter {

    var maxAllowed: Int

    init(maxAllowed: Int) {
        self.maxAllowed = maxAllowed
    }

    private(set) var emitted: Int = 0
    private(set) var dissolved: Int = 0
    private(set) var enteredWater: Int = 0

    mutating func didEmit() {
        emitted += 1
    }

    mutating func didDissolve() {
        dissolved += 1
    }

    mutating func didEnterWater() {
        enteredWater += 1
    }

    mutating func reset() {
        emitted = 0
        dissolved = 0
        enteredWater = 0
    }

    var canEmit: Bool {
        emitted < maxAllowed
    }

    var canDissolve: Bool {
        dissolved < maxAllowed
    }

    var dissolvedFraction: CGFloat {
        CGFloat(dissolved) / CGFloat(maxAllowed)
    }

    var enteredWaterFraction: CGFloat {
        CGFloat(enteredWater) / CGFloat(maxAllowed)
    }
}
