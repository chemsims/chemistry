//
// Reactions App
//

import SwiftUI
import ReactionsCore

class ShakeContainerViewModel: NSObject, ObservableObject {

    let motion: CoreMotionShakingViewModel
    @Published var molecules = [FallingMolecule]()

    let canAddMolecule: () -> Bool
    let addMolecules: (Int) -> Void

    var initialLocation: CGPoint?
    var bottomY: CGFloat?

    init(
        canAddMolecule: @escaping () -> Bool,
        addMolecules: @escaping (Int) -> Void
    ) {
        self.motion = CoreMotionShakingViewModel(settings: .defaultBehavior)
        self.canAddMolecule = canAddMolecule
        self.addMolecules = addMolecules
        super.init()
        self.motion.delegate = self
    }

    private let velocity = 200.0 // pts per second

    func manualAdd() {
        doManualAdd(remaining: 5)
    }

    private func doManualAdd(remaining: Int) {
        guard motion.position.isUpdating && remaining > 0 else {
            return
        }
        doAdd()
        let nextDelay = Double.random(in: 0.05...0.1)
        DispatchQueue.main.asyncAfter(deadline: .now() + nextDelay) {
            self.doManualAdd(remaining: remaining - 1)
        }
    }

    private func doAdd() {
        guard canAddMolecule() else {
            return
        }
        if let location = initialLocation, let bottomY = bottomY {
            let molecule = FallingMolecule(
                position: CGPoint(
                    x: location.x + motion.position.xOffset,
                    y: location.y + motion.position.yOffset
                )
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

extension ShakeContainerViewModel: CoreMotionShakingDelegate {
    func didShake() {
        doAdd()
    }
}
