//
// Reactions App
//

import CoreMotion
import CoreGraphics

/// Provides a hook to run an action whenever the device has been shook.
///
/// The shaking sensitivity is based on configurable thresholds.
public final class CoreMotionShakingViewModel: NSObject, CoreMotionDevicePositionDelegate {

    public let settings: CoreMotionShakingBehavior
    public let position: CoreMotionPositionViewModel

    public weak var delegate: CoreMotionShakingDelegate?

    public init(settings: CoreMotionShakingBehavior, delegate: CoreMotionShakingDelegate? = nil) {
        self.position = CoreMotionPositionViewModel()
        self.settings = settings
        self.delegate = delegate
        super.init()
        position.delegate = self
    }

    private var lastShake: Date?

    public func handleMotionUpdate(motion: CMDeviceMotion) {
        let rotationRateMag = motion.rotationRate.magnitude
        if let timeInterval = settings.getTimeInterval(for: CGFloat(rotationRateMag)) {
            let now = Date()
            let enoughTimeHasPassed = lastShake.map {
                now.timeIntervalSince($0) >= Double(timeInterval)
            }
            if enoughTimeHasPassed ?? true {
                lastShake = now
                delegate?.didShake()
            }
        }
    }
}
