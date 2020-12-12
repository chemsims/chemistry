//
// Reactions App
//
  

import CoreGraphics

struct BoundedSliderPositioning {

    let axis: AxisPositionCalculations<CGFloat>
    let absoluteMin: CGFloat
    let absoluteMax: CGFloat

    /// The maximum value the value may be, before accounting for spacing
    /// i.e., the minimum must be above this value, plus a distance of `spacing`
    let minPreSpacing: CGFloat?
    /// The maximum value the value may be, before accounting for spacing
    let maxPreSpacing: CGFloat?

    /// The  spacing to place between value bounds. .ie., the value1Min must be > value2 min, plus the spacing
    let spacing: CGFloat


    /// An axis with updated upper and lower bounds
    var boundedAxis: AxisPositionCalculations<CGFloat> {
        let absoluteBounds = axis.updateMin(value: absoluteMin).updateMax(value: absoluteMax)
        let updatedLower = updateLowerBounds(axis: absoluteBounds)
        return updateUpperBounds(axis: updatedLower)
    }

    private func updateLowerBounds(axis: AxisPositionCalculations<CGFloat>) -> AxisPositionCalculations<CGFloat> {
        if let minWithSpacing = minPreSpacing {
            let direction = axis.minValuePosition < axis.maxValuePosition ? 1 : -1
            let minPositionPreSpacing = axis.getPosition(at: minWithSpacing)
            let newMinPosition = minPositionPreSpacing + (spacing * CGFloat(direction))
            let updated = axis.updateMin(position: newMinPosition)
            if (updated.minValue < absoluteMin) {
                return axis
            }
            return updated
        }
        return axis
    }

    private func updateUpperBounds(axis: AxisPositionCalculations<CGFloat>) -> AxisPositionCalculations<CGFloat> {
        if let maxWithSpacing = maxPreSpacing {
            let direction = axis.minValuePosition < axis.maxValuePosition ? 1 : -1
            let maxPositionPreSpacing = axis.getPosition(at: maxWithSpacing)
            let newMaxPosition = maxPositionPreSpacing - (spacing * CGFloat(direction))
            let updated = axis.updateMax(position: newMaxPosition)
            if (updated.maxValue > absoluteMax) {
                return axis
            }
            return updated
        }
        return axis
    }
}
