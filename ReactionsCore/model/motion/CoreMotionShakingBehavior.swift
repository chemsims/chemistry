//
// Reactions App
//

import CoreGraphics

public struct CoreMotionShakingBehavior {

    let minTimeInterval: CGFloat
    let maxTimeInterval: CGFloat
    let minRotationThreshold: CGFloat
    let maxRotationRate: CGFloat

    public init(
        minTimeInterval: CGFloat,
        maxTimeInterval: CGFloat,
        minRotationThreshold: CGFloat,
        maxRotationRate: CGFloat
    ) {
        self.minTimeInterval = minTimeInterval
        self.maxTimeInterval = maxTimeInterval
        self.minRotationThreshold = minRotationThreshold
        self.maxRotationRate = maxRotationRate
    }

    public static var defaultBehavior: CoreMotionShakingBehavior {
        CoreMotionShakingBehavior(
            minTimeInterval: 0.035,
            maxTimeInterval: 0.25,
            minRotationThreshold: 1.5,
            maxRotationRate: 10
        )
    }

    func getTimeInterval(for rotationRate: CGFloat) -> CGFloat? {
        guard rotationRate >= minRotationThreshold else {
            return nil
        }
        return timeIntervalEquation
            .getValue(at: rotationRate)
            .within(min: minTimeInterval, max: maxTimeInterval)
    }

    private var timeIntervalEquation: LinearEquation {
        LinearEquation(
            x1: minRotationThreshold,
            y1: minTimeInterval,
            x2: maxRotationRate,
            y2: maxTimeInterval
        )
    }
}
