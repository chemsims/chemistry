//
// Reactions App
//

import Foundation
import ReactionsCore

class PumpViewModel<Value: BinaryFloatingPoint> {

    let initialExtensionFactor: Value
    let divisions: Int
    let onDownPump: () -> Void

    private let deltaValue: Value

    init(
        initialExtensionFactor: Value,
        divisions: Int,
        onDownPump: @escaping () -> Void
    ) {
        precondition(divisions > 0)
        self.initialExtensionFactor = initialExtensionFactor
        self.divisions = divisions
        self.onDownPump = onDownPump
        self.oldValue = 1 - initialExtensionFactor
        self.deltaValue = 1 / Value(divisions)
    }

    private var oldValue: Value

    func moved(to newExtensionFactor: Value) {
        let newValue = (1 - newExtensionFactor)
        let divisionsBeforeOld = getDivisions(before: oldValue)
        let divisionsBeforeNew = getDivisions(before: newValue)
        let divisionsMoved = divisionsBeforeNew - divisionsBeforeOld
        if divisionsMoved > 0 {
            (0..<divisionsMoved).forEach { _ in
                onDownPump()
            }
        }
        oldValue = newValue
    }

    private func getDivisions(before value: Value) -> Int {
        Int(value / deltaValue)
    }
}
