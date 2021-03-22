//
// Reactions App
//

import CoreGraphics
import ReactionsCore

struct GridUtil {

    /// Returns the number of rows available for molecules
    static func availableRows(for rows: CGFloat) -> Int {
        if rows - rows.rounded(.down) > 0.4 {
            assert(Int(rows) != Int(ceil(rows)), "\(rows)")
            return Int(ceil(rows))
        }
        return Int(rows)
    }

    /// Finding concentration using the molecule count may differ from the previously converged value
    /// So, if molecules unchanged, use the previous equilibrium value
    static func initialConcentration(
        of molecule: AqueousMolecule,
        coords: [GridCoordinate],
        gridSize: Int,
        previousCoords: [GridCoordinate]?,
        previousEquation: BalancedReactionEquation?,
        at time: CGFloat,
        rowsHaveChangeFromPrevious: Bool?
    ) -> CGFloat {
        let defaultValue = CGFloat(coords.count) / CGFloat(gridSize)
        if let prevCoords = previousCoords, let prevEquation = previousEquation {
            let current = coords
            if prevCoords.count == current.count && !(rowsHaveChangeFromPrevious ?? false) {
                return prevEquation.concentration.value(for: molecule).getY(at: time)
            }
        }
        return defaultValue
    }
}

