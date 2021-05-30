//
// Reactions App
//

import SwiftUI

/// A view model to handle multiple containers where at most 1 container is active at a time
public class MultiContainerShakeViewModel<MoleculeType>: ObservableObject
    where MoleculeType : CaseIterable, MoleculeType : Hashable {

    @Published public var activeMolecule: MoleculeType?

    public init(
        canAddMolecule: @escaping (MoleculeType) -> Bool,
        addMolecules: @escaping (MoleculeType, Int) -> Void
    ) {
        self.models = EnumMap { molecule in
            ShakeContainerViewModel(
                canAddMolecule: { canAddMolecule(molecule) },
                addMolecules: { addMolecules(molecule, $0) }
            )
        }
    }

    public let models: EnumMap<MoleculeType, ShakeContainerViewModel>

    public func model(for molecule: MoleculeType) -> ShakeContainerViewModel {
        models.value(for: molecule)
    }

    public func start(
        for molecule: MoleculeType,
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

    public func stopAll() {
        stopShaking()
        withAnimation(.spring()) {
            activeMolecule = nil
        }
    }

    private func stopShaking() {
        models.all.forEach { $0.motion.position.stop() }
    }
}
