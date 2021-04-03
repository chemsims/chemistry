//
// Reactions App
//

import SwiftUI
import CoreMotion

/// Provides x & y offsets in response to device movement
public class CoreMotionPositionViewModel: ObservableObject {

    public init() { }

    @Published public var xOffset: CGFloat = 0
    @Published public var yOffset: CGFloat = 0

    private var halfYRange: CGFloat?

    private var halfXRange: CGFloat?

    public weak var delegate: CoreMotionDevicePositionDelegate?

    public private(set) var isUpdating = false

    private let motion = CMMotionManager()
    private var initialAttitude: CMAttitude?


    /// Starts motion updates
    ///
    /// - Parameters:
    ///     - halfXRange: Half of the range that the x offset can vary
    ///     - halfYRange: Half of the range that the y offset can vary
    public func start(halfXRange: CGFloat, halfYRange: CGFloat) {
        self.halfXRange = halfXRange
        self.halfYRange = halfYRange
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

    public func stop() {
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
        delegate?.handleMotionUpdate(motion: motion)
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
