//
// Reactions App
//

import CoreGraphics
import ReactionsCore

struct ChemicalReactionsSettings {
    private init() { }
    
    static let minRows = 6
    static let maxRows = 14

    static let initialRows = (minRows + maxRows) / 2

    static let rowsToVolume = LinearEquation(
        x1: CGFloat(minRows),
        y1: 0.1,
        x2: CGFloat(maxRows),
        y2: 0.7
    )

    /// Returns rotation of the balanced reaction scales as a fraction between -1 and 1,
    /// in terms of the surplus of product atoms, which may be negative
    static let productAtomSurplusToRotation: Equation = {
        let maxDifference: CGFloat = 3
        return LinearEquation(
            x1: -maxDifference,
            y1: -1,
            x2: maxDifference,
            y2: 1
        ).within(min: -1, max: 1)
    }()
}
