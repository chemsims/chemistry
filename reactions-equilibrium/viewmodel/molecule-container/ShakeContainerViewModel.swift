//
// Reactions App
//

import CoreGraphics
import CoreMotion
import ReactionsCore
import SwiftUI

class NewAddingSingleMoleculeViewModel: ObservableObject {

    @Published var xOffset: CGFloat = 0
    @Published var yOffset: CGFloat = 0
    @Published var molecules = [FallingMolecule]()

    var canAddMolecule: (() -> Bool)?
    var addMolecules: ((Int) -> Void)?

    var initialLocation: CGPoint?
    var halfXRange: CGFloat?
    var halfYRange: CGFloat?
    var bottomY: CGFloat?

    private var lastDrop: Date?
    private let motion = CMMotionManager()
    private let velocity = 200.0 // pts per second

    private var initialAcceleration: CMAcceleration?
    private var initialAttitude: CMAttitude?

    func startMoleculeShake() {
        if motion.isDeviceMotionAvailable {
            motion.deviceMotionUpdateInterval = 1 / 120
            motion.showsDeviceMovementDisplay = true
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

    private func handleMotionUpdate(motion: CMDeviceMotion) {
        if let initialAttitude = initialAttitude {
            handlePitch(newValue: motion.attitude.pitch - initialAttitude.pitch)
            handleRoll(newValue: motion.attitude.roll - initialAttitude.roll)
        }

        let rotationRateMag = motion.rotationRate.magnitude

        if let timeInterval = AddingMoleculesSettings.getTimeInterval(rotationRate: CGFloat(rotationRateMag)) {
            let enoughTimeHasPassed = lastDrop.map { Date().timeIntervalSince($0) >= Double(timeInterval) }
            if enoughTimeHasPassed ?? true {
                lastDrop = Date()
                doAdd()
            }
        }
    }

    private let pitchEquation = LinearEquation(x1: 0.5, y1: -1, x2: -0.5, y2: 1)
    private func handlePitch(newValue: Double) {
        let pitchFactor = within(min: -1, max: 1, value: pitchEquation.getY(at: CGFloat(newValue)))
        self.xOffset = self.halfXRange.map { $0 * pitchFactor } ?? 0
    }


    private let rollEquation = LinearEquation(x1: -0.5, y1: -1, x2: 0.5, y2: 1)
    private func handleRoll(newValue: Double) {
        let rollFactor = within(min: -1, max: 1, value: rollEquation.getY(at: CGFloat(newValue)))
        self.yOffset = self.halfYRange.map { $0 * rollFactor } ?? 0
    }

    func stopMoleculeShake() {
        motion.stopDeviceMotionUpdates()
    }

    private func doAdd() {
        guard canAddMolecule?() ?? false else {
            return
        }

        if let location = initialLocation, let bottomY = bottomY {
            let molecule = FallingMolecule(
                position: CGPoint(x: location.x + xOffset, y: location.y + yOffset)
            )
            molecules.append(molecule)

            let dy = bottomY - location.y
            let duration = Double(dy) / velocity

            withAnimation(.linear(duration: duration)) {
                molecules[molecules.count - 1].position = CGPoint(x: molecule.position.x, y: bottomY)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.moleculeHasHitWater(id: molecule.id)
            }
        }
    }

    private func moleculeHasHitWater(id: UUID) {
        if let index = molecules.firstIndex(where: { $0.id == id }) {
            molecules.remove(at: index)
        }
        if let doAddMolecules = addMolecules {
            doAddMolecules(1)
        }
    }
}

private extension CMRotationRate {
    var magnitude: Double {
        sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2))
    }
}
