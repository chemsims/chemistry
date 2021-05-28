//
// Reactions App
//

import SwiftUI

/// A view model to handle shaking molecules from a container, and performing some action when entering the water
public class ShakeContainerViewModel: NSObject, ObservableObject {

    /// Creates a new model
    ///
    /// - Parameters:
    ///     - canAddMolecule: A closure to configure whether the container can emit new molecules
    ///     - addMolecules: A closure called when molecules enter the water. The integer passed to the
    ///                     closure will be the number of molecules entering the water. Note that this may be
    ///                     greater than 1.
    public init(
        canAddMolecule: @escaping () -> Bool,
        addMolecules: @escaping (Int) -> Void
    ) {
        self.motion = CoreMotionShakingViewModel(
            settings: .defaultBehavior
        )
        self.canAddMolecule = canAddMolecule
        self.addMolecules = addMolecules
        super.init()
        self.motion.delegate = self
    }

    public let motion: CoreMotionShakingViewModel
    @Published public var molecules = [MovingPoint]()

    public let canAddMolecule: () -> Bool
    public let addMolecules: (Int) -> Void

    public var initialLocation: CGPoint?
    public var bottomY: CGFloat?

    public var halfXRange: CGFloat?
    public var halfYRange: CGFloat?

    private let velocity = 200.0 // pts per second
    private let maxDuration: Double = 1.5

    public func manualAdd(amount: Int) {
        doManualAdd(remaining: amount)
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
            let molecule = MovingPoint(
                position: CGPoint(
                    x: location.x + (motion.position.xOffset * (halfXRange ?? 0)),
                    y: location.y + (motion.position.yOffset * (halfYRange ?? 0))
                )
            )
            molecules.append(molecule)

            let dy = bottomY - location.y
            let duration = min(maxDuration, Double(dy) / velocity)

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
    public func didShake() {
        DispatchQueue.main.async { [weak self] in
            self?.doAdd()
        }
    }
}
