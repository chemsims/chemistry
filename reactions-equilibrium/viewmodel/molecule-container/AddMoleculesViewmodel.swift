//
// Reactions App
//

import SwiftUI
import ReactionsCore
import CoreMotion

class AddingMoleculesViewModel: ObservableObject {

    @Published var activeMolecule: AqueousMolecule?
    let canAddMolecule: (AqueousMolecule) -> Bool
    let addMolecules: (AqueousMolecule, Int) -> Void

    init(canAddMolecule: @escaping (AqueousMolecule) -> Bool, addMolecules: @escaping (AqueousMolecule, Int) -> Void) {
        self.canAddMolecule = canAddMolecule
        self.addMolecules = addMolecules

        func model(_ molecule: AqueousMolecule) -> ShakeContainerViewModel {
            ShakeContainerViewModel(
                canAddMolecule: { canAddMolecule(molecule) },
                addMolecules: { addMolecules(molecule, $0) }
            )
        }

        self.models = MoleculeValue(builder: model)
    }

    let models: MoleculeValue<ShakeContainerViewModel>

    func start(
        for molecule: AqueousMolecule,
        at location: CGPoint,
        bottomY: CGFloat,
        halfXRange: CGFloat,
        halfYRange: CGFloat
    ) {
        stopShaking()
        let model = models.value(for: molecule)
        model.initialLocation = location
        model.halfXRange = halfXRange
        model.halfYRange = halfYRange
        model.bottomY = bottomY
        model.motion.position.start()
    }

    func stopAll() {
        stopShaking()
        withAnimation(.spring()) {
            activeMolecule = nil
        }
    }

    private func stopShaking() {
        models.all.forEach { $0.motion.position.stop() }
    }
}

struct AddingMoleculesSettings {

    static func getTimeInterval(for rotationRate: CGFloat) -> CGFloat? {
        guard rotationRate >= minThreshold else {
            return nil
        }
        return rotationTimeIntervalEquation.getY(at: rotationRate).within(min: minTimeInterval, max: maxTimeInterval)
    }

    private static let minTimeInterval: CGFloat = 0.035
    private static let maxTimeInterval: CGFloat = 0.25
    private static let minThreshold: CGFloat = 1.5
    private static let maxRotationRate: CGFloat = 10
    private static let rotationTimeIntervalEquation = LinearEquation(
        x1: minThreshold,
        y1: minTimeInterval,
        x2: maxRotationRate,
        y2: maxTimeInterval
    )
}
