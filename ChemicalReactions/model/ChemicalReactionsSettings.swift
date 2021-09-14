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
}
