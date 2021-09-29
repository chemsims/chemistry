//
// Reactions App
//

import CoreGraphics

public struct BeakerGrid {

    public init(rows: Int, cols: Int) {
        self.rows = rows
        self.cols = cols
    }

    public let rows: Int
    public let cols: Int

    public var size: Int {
        rows * cols
    }

    public func count(concentration: CGFloat) -> Int {
        (concentration * CGFloat(size)).roundedInt()
    }
}
