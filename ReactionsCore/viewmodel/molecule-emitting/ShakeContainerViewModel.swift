//
// Reactions App
//

import SwiftUI

/// A view model to handle shaking molecules from a container, and performing some action when entering the water
public class ShakeContainerViewModel: NSObject, ObservableObject, MoleculeEmittingContainer {

    /// Creates a new model
    ///
    /// - Parameters:
    ///     - canAddMolecule: A closure to configure whether the container can emit new molecules
    ///     - addMolecules: A closure called when molecules enter the water. The integer passed to the
    ///                     closure will be the number of molecules entering the water. Note that this may be
    ///                     greater than 1.
    public init(
        canAddMolecule: @escaping () -> Bool,
        didEmitMolecules: @escaping (Int) -> Void = { _ in },
        addMolecules: @escaping (Int) -> Void
    ) {
        self.motion = CoreMotionShakingViewModel(
            settings: .defaultBehavior
        )
        self.canAddMolecule = canAddMolecule
        self.addMolecules = addMolecules
        self.didEmitMolecules = didEmitMolecules
        super.init()
        self.motion.delegate = self
        self.emitter = MoleculeEmitter(underlyingMolecules: self)
    }

    public let motion: CoreMotionShakingViewModel
    @Published public var molecules = [MovingPoint]()

    func canEmitMolecule() -> Bool {
        motion.position.isUpdating && self.canAddMolecule()
    }

    func addMolecules(count: Int) {
        self.addMolecules(1)
    }

    func didEmitMolecules(count: Int) {
        self.didEmitMolecules(count)
    }

    public let canAddMolecule: () -> Bool
    public let didEmitMolecules: (Int) -> Void
    public let addMolecules: (Int) -> Void

    public var initialLocation: CGPoint?
    public var bottomY: CGFloat?

    public var halfXRange: CGFloat?
    public var halfYRange: CGFloat?

    private var emitter: MoleculeEmitter?

    public func manualAdd(amount: Int) {
        guard let emitter = emitter, let location = initialLocation, let bottomY = bottomY else {
            return
        }
        emitter.manualAdd(amount: amount, at: location, bottomY: bottomY)
    }

    private func doAdd() {
        guard let emitter = self.emitter else {
            return
        }
        guard canAddMolecule() else {
            return
        }
        if let location = initialLocation, let bottomY = bottomY {

            let location = CGPoint(
                x: location.x + (motion.position.xOffset * (halfXRange ?? 0)),
                y: location.y + (motion.position.yOffset * (halfYRange ?? 0))
            )
            emitter.doAdd(
                at: location,
                bottomY: bottomY
            )
        }
    }
}

extension ShakeContainerViewModel: CoreMotionShakingDelegate {
    public func didShake() {
        DispatchQueue.main.async { [weak self] in
            self?.doAdd()
        }
    }
}
