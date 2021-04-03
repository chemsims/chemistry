//
// Reactions App
//

import CoreMotion

public protocol CoreMotionDevicePositionDelegate: NSObjectProtocol {
    func handleMotionUpdate(motion: CMDeviceMotion)
}

public protocol CoreMotionShakingDelegate: NSObjectProtocol {
    func didShake()
}
