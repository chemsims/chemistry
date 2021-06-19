//
// Reactions App
//

import SwiftUI

/// A view model to handle emitting molecules from a fixed point
public class MoleculeEmittingViewModel: ObservableObject, MoleculeEmittingContainer {

    public init(
        canAddMolecule: @escaping () -> Bool,
        doAddMolecule: @escaping (Int) -> Void
    ) {
        self.canAddMolecule = canAddMolecule
        self.doAddMolecule = doAddMolecule
        self.emitter = MoleculeEmitter(underlyingMolecules: self)
    }

    @Published public var molecules = [MovingPoint]()

    private let canAddMolecule: () -> Bool
    private let doAddMolecule: (Int) -> Void
    private var emitter: MoleculeEmitter?

    public func addMolecule(
        amount: Int,
        at location: CGPoint,
        bottomY: CGFloat
    ) {
        guard let emitter = emitter else {
            return
        }
        emitter.manualAdd(amount: amount, at: location, bottomY: bottomY)
    }

    func canEmitMolecule() -> Bool {
        canAddMolecule()
    }

    func addMolecules(count: Int) {
        doAddMolecule(count)
    }

}
