//
// Reactions App
//

import CoreGraphics

struct GridUtil {

    /// Returns the number of rows available for molecules
    static func availableRows(for rows: CGFloat) -> Int {
        if rows - rows.rounded(.down) > 0.4 {
            assert(Int(rows) != Int(ceil(rows)), "\(rows)")
            return Int(ceil(rows))
        }
        return Int(rows)
    }
}

