//
// Reactions App
//

import CoreGraphics
import CoreMotion
import ReactionsCore
import SwiftUI

class ShakeContainerViewModel: ObservableObject {

    @Published var xOffset: CGFloat = 0
    @Published var yOffset: CGFloat = 0
    @Published var molecules = [FallingMolecule]()

    let canAddMolecule: () -> Bool
    let addMolecules: (Int) -> Void

    var initialLocation: CGPoint?
    var halfXRange: CGFloat?
    var halfYRange: CGFloat?
    var bottomY: CGFloat?

    private var lastDrop: Date?
    private let motion = CMMotionManager()
    private let velocity = 200.0 // pts per second

    private var initialAttitude: CMAttitude?

    private var isUpdating = false

    init(
        canAddMolecule: @escaping () -> Bool,
        addMolecules: @escaping (Int) -> Void
    ) {
        self.canAddMolecule = canAddMolecule
        self.addMolecules = addMolecules
    }

    func startMoleculeShake() {
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

    func stopMoleculeShake() {
        isUpdating = false
        motion.stopDeviceMotionUpdates()
        initialAttitude = nil
        withAnimation(.easeOut(duration: 0.25)) {
            xOffset = 0
            yOffset = 0
        }
    }


    func manualAdd() {
        doManualAdd(remaining: 5)
    }

    private func doManualAdd(remaining: Int) {
        guard isUpdating && remaining > 0 else {
            return
        }
        doAdd()
        let nextDelay = Double.random(in: 0.05...0.1)
        DispatchQueue.main.asyncAfter(deadline: .now() + nextDelay) {
            self.doManualAdd(remaining: remaining - 1)
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

        let rotationRateMag = motion.rotationRate.magnitude
        if let timeInterval = AddingMoleculesSettings.getTimeInterval(for: CGFloat(rotationRateMag)) {
            let enoughTimeHasPassed = lastDrop.map { Date().timeIntervalSince($0) >= Double(timeInterval) }
            if enoughTimeHasPassed ?? true {
                lastDrop = Date()
                doAdd()
            }
        }
    }

    private let pitchEquation = LinearEquation(x1: 0.5, y1: -1, x2: -0.5, y2: 1)
    private func handlePitch(newValue: Double) {
        self.xOffset = getOffset(equation: pitchEquation, value: newValue, halfRange: halfXRange)
    }


    private let rollEquation = LinearEquation(x1: -0.5, y1: -1, x2: 0.5, y2: 1)
    private func handleRoll(newValue: Double) {
        self.yOffset = getOffset(equation: rollEquation, value: newValue, halfRange: halfYRange)
    }

    private func getOffset(equation: Equation, value: Double, halfRange: CGFloat?) -> CGFloat {
        let factor = within(min: -1, max: 1, value: equation.getY(at: CGFloat(value)))
        return halfRange.map { $0 * factor } ?? 0
    }

    private func doAdd() {
        guard canAddMolecule() else {
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
        addMolecules(1)
    }
}

private extension CMRotationRate {
    var magnitude: Double {
        sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2))
    }
}
