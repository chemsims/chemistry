//
// Reactions App
//

import SwiftUI
import CoreMotion

/// Provides x & y offsets in response to device movement
public class CoreMotionPositionViewModel: ObservableObject {

    public init() {
        self.queue = OperationQueue()
        self.queue.qualityOfService = .userInteractive
    }

    private let queue: OperationQueue

    /// The x offset, which will lie between -1 and 1
    @Published public var xOffset: CGFloat = 0
    @Published public var yOffset: CGFloat = 0

    public weak var delegate: CoreMotionDevicePositionDelegate?

    public private(set) var isUpdating = false

    private let motion = CMMotionManager()
    private var initialAttitude: CMAttitude?

    /// Starts motion updates
    public func start() {
        guard !isUpdating else {
            return
        }
        isUpdating = true
        if motion.isDeviceMotionAvailable {
            motion.deviceMotionUpdateInterval = 1 / 60
            motion.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: queue) { (data, error) in
                if let data = data {
                    if self.initialAttitude == nil {
                        self.initialAttitude = data.attitude
                    }
                    self.handleMotionUpdate(motion: data)
                }
            }
        }
    }

    /// Stops motion updates
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
            DispatchQueue.main.async { [weak self] in
                self?.handlePitch(newValue: motion.attitude.pitch - initialAttitude.pitch)
                self?.handleRoll(newValue: motion.attitude.roll - initialAttitude.roll)
            }
        }
        delegate?.handleMotionUpdate(motion: motion)
    }

    private let pitchEquation = LinearEquation(x1: 0.5, y1: -1, x2: -0.5, y2: 1)
    private let rollEquation = LinearEquation(x1: -0.5, y1: -1, x2: 0.5, y2: 1)

    private func handlePitch(newValue: Double) {
        self.xOffset = getOffset(
            value: newValue,
            equation: pitchEquation
        )
    }

    private func handleRoll(newValue: Double) {
        self.yOffset = getOffset(
            value: newValue,
            equation: rollEquation
        )
    }

    private func getOffset(value: Double, equation: Equation) -> CGFloat {
        within(min: -1, max: 1, value: equation.getY(at: CGFloat(value)))
    }
}
