//
// Reactions App
//

import CoreGraphics

/// Helper to find axis limits such that `middlePh` is in the middle of the axis.
///
/// `middlePh` will be in the middle of the axis, while `initialPh` will be contained
/// within the axis somewhere. The `minDelta` will also be satisfied, such that the
/// distance from `middlePh` to the axis limits will be the bigger of `minDelta`, or
/// `abs(middlePh - initialPh)`.
struct FractionedChartAxisHelper {
    init(
        initialPh: CGFloat,
        middlePh: CGFloat,
        minDelta: CGFloat
    ) {
        self.initialPh = initialPh
        self.middlePh = middlePh
        self.minDelta = minDelta
    }

    let initialPh: CGFloat
    let middlePh: CGFloat
    let minDelta: CGFloat

    var minValue: CGFloat {
        middlePh - delta
    }

    var maxValue: CGFloat {
        middlePh + delta
    }

    private var delta: CGFloat {
        let deltaToInitial = abs(middlePh - initialPh)
        return max(deltaToInitial, abs(minDelta))
    }
}
