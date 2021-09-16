//
// Reactions App
//

import SwiftUI

/// A view model to handle emitting molecules from a fixed point
public class MoleculeEmittingViewModel: ObservableObject, MoleculeEmittingContainer {


    /// - Parameter useBufferWhenAddingMolecules: Whether to call `addMolecules` once for any
    /// molecules which hit the water within short buffer window. When false, molecules will be added immediately
    /// when they hit the water. This may cause a performance issue if `addMolecules` is a relatively expensive operation.
    public init(
        canAddMolecule: @escaping () -> Bool,
        didEmitMolecules: @escaping (Int) -> Void = { _ in },
        doAddMolecule: @escaping (Int) -> Void,
        useBufferWhenAddingMolecules: Bool
    ) {
        self.canAddMolecule = canAddMolecule
        self.didEmitMolecules = didEmitMolecules
        self.doAddMolecule = doAddMolecule
        self.emitter = MoleculeEmitter(
            underlyingMolecules: self,
            useBufferWhenAddingMolecules: useBufferWhenAddingMolecules
        )
    }

    @Published public var molecules = [MovingPoint]()

    private let canAddMolecule: () -> Bool
    private let didEmitMolecules: (Int) -> Void
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

    func didEmitMolecules(count: Int) {
        self.didEmitMolecules(count)
    }

}
