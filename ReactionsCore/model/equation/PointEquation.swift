//
// Reactions App
//

import CoreGraphics

public protocol PointEquation {
    func getPoint(at progress: CGFloat) -> CGPoint
}

struct ConstantPointEquation: PointEquation {
    init(_ value: CGPoint) {
        self.value = value
    }

    let value: CGPoint

    func getPoint(at progress: CGFloat) -> CGPoint {
        value
    }
}

struct SwitchingPointEquation: PointEquation {
    let left: PointEquation
    let right: PointEquation
    let thresholdProgress: CGFloat

    func getPoint(at progress: CGFloat) -> CGPoint {
        if progress < thresholdProgress {
            return left.getPoint(at: progress)
        }
        return right.getPoint(at: progress)
    }
}

struct LinearPointEquation: PointEquation {

    init(initial: CGPoint, final: CGPoint, initialProgress: CGFloat = 0, finalProgress: CGFloat = 1) {
        self.underlying = WrappedPointEquation(
            xEquation: LinearEquation(
                x1: initialProgress,
                y1: initial.x,
                x2: finalProgress,
                y2: final.x
            ),
            yEquation: LinearEquation(
                x1: initialProgress,
                y1: initial.y,
                x2: finalProgress,
                y2: final.y
            )
        )
    }

    private let underlying: WrappedPointEquation

    func getPoint(at progress: CGFloat) -> CGPoint {
        underlying.getPoint(at: progress)
    }
}

struct WrappedPointEquation: PointEquation {
    let xEquation: Equation
    let yEquation: Equation

    func getPoint(at progress: CGFloat) -> CGPoint {
        CGPoint(
            x: xEquation.getY(at: progress),
            y: yEquation.getY(at: progress)
        )
    }
}
