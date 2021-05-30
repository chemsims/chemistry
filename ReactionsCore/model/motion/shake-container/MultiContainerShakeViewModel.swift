//
// Reactions App
//

import SwiftUI

/// A protocol to handle multiple containers where at most 1 container is active at a time
public protocol MultiContainerShakeViewModel: ObservableObject {
    associatedtype MoleculeType

    var activeMolecule: MoleculeType? { get set }
    var allModels: [ShakeContainerViewModel] { get }
    func model(for molecule: MoleculeType) -> ShakeContainerViewModel
}

extension MultiContainerShakeViewModel {

    public func start(
        for molecule: MoleculeType,
        at location: CGPoint,
        bottomY: CGFloat,
        halfXRange: CGFloat,
        halfYRange: CGFloat
    ) {
        stopShaking()
        let model = model(for: molecule)
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
        allModels.forEach { $0.motion.position.stop() }
    }
}
