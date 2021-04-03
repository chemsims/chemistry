//
// Reactions App
//

import SwiftUI
import CoreMotion

/// Provides x & y offsets in response to device movement
public class CoreMotionMovableElementViewModel {

    @Published public var xOffset: CGFloat = 0
    @Published public var yOffset: CGFloat = 0

    /// Half of the range that the x offset can vary
    public var halfYRange: CGFloat?

    /// Half of the range that the y offset can vary
    public var halfXRange: CGFloat?

    weak var delegate: CoreMotionDeviceMovedDelegate?

    private let motion = CMMotionManager()

    private var initialAttitude: CMAttitude?
    private var isUpdating = false

    func start() {
        guard !isUpdating else {
            return
        }
        isUpdating = true
        if motion.isDeviceMotionAvailable {
            motion.deviceMotionUpdateInterval = 1 / 120
            motion.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: .main) { (data, error) in
                if let data = data {
                    if self.initialAttitude == nil {
                        self.initialAttitude = data.attitude
                    }
                    self.handleMotionUpdate(motion: data)
                }
            }
        }
    }

    func stop() {
        isUpdating = false
        motion.stopDeviceMotionUpdates()
        initialAttitude = nil
        withAnimation(.easeOut(duration: 0.25)) {
            xOffset = 0
            yOffset = 0
        }
    }

    private func handleMotionUpdate(motion: CMDeviceMotion) {
        guard isUpdating else {
            return
        }
        if let initialAttitude = initialAttitude {
            handlePitch(newValue: motion.attitude.pitch - initialAttitude.pitch)
            handleRoll(newValue: motion.attitude.roll - initialAttitude.roll)
        }
    }

    private let pitchEquation = LinearEquation(x1: 0.5, y1: -1, x2: -0.5, y2: 1)
    private let rollEquation = LinearEquation(x1: -0.5, y1: -1, x2: 0.5, y2: 1)

    private func handlePitch(newValue: Double) {
        self.xOffset = getOffset(
            value: newValue,
            equation: pitchEquation,
            halfRange: halfXRange
        )
    }

    private func handleRoll(newValue: Double) {
        self.yOffset = getOffset(
            value: newValue,
            equation: rollEquation,
            halfRange: halfYRange
        )
    }

    private func getOffset(value: Double, equation: Equation, halfRange: CGFloat?) -> CGFloat {
        let factor = within(min: -1, max: 1, value: equation.getY(at: CGFloat(value)))
        return halfRange.map { $0 * factor } ?? 0
    }
}


open class CoreMotionDeviceMovedDelegate {
    func handleMotionUpdate(motion: CMDeviceMotion) { }
}

/// Provides a hook to run an action whenever the device has been shook.
///
/// The shaking sensitivity is based on configurable thresholds.
public class CoreMotionShakingElementDelegate: CoreMotionDeviceMovedDelegate {

    let settings: CoreMotionShakingBehavior
    let action: () -> Void

    init(settings: CoreMotionShakingBehavior, onEmit: @escaping () -> Void) {
        self.settings = settings
        self.action = onEmit
    }

    private var lastAction: Date?

    override func handleMotionUpdate(motion: CMDeviceMotion) {
        let rotationRateMag = motion.rotationRate.magnitude
        if let timeInterval = settings.getTimeInterval(for: CGFloat(rotationRateMag)) {
            let now = Date()
            let enoughTimeHasPassed = lastAction.map {
                now.timeIntervalSince($0) >= Double(timeInterval)
            }
            if enoughTimeHasPassed ?? true {
                lastAction = now
                action()
            }
        }
    }
}

struct CoreMotionShakingBehavior {
    let minTimeInterval: CGFloat
    let maxTimeInterval: CGFloat
    let minRotationThreshold: CGFloat
    let maxRotationRate: CGFloat

    func getTimeInterval(for rotationRate: CGFloat) -> CGFloat? {
        guard rotationRate >= minRotationThreshold else {
            return nil
        }
        return timeIntervalEquation
            .getY(at: rotationRate)
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


private extension CMRotationRate {
    var magnitude: Double {
        sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2))
    }
}
