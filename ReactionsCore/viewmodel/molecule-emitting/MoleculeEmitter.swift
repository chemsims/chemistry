//
// Reactions App
//

import SwiftUI

/// Container for an array of molecules which should be emitted
protocol MoleculeEmittingContainer: AnyObject {
    var molecules: [MovingPoint] { get set }

    func canEmitMolecule() -> Bool
    func didEmitMolecules(count: Int) -> Void
    func addMolecules(count: Int) -> Void
}

/// Handles updates to an underlying array of molecules, to emit & drop molecules into water.
class MoleculeEmitter {

    /// Create a new instance using the `underlyingMolecules`
    init(underlyingMolecules: MoleculeEmittingContainer) {
        self.underlyingMolecules = underlyingMolecules
    }

    weak var underlyingMolecules: MoleculeEmittingContainer?

    private let velocity = 200.0 // pts per second
    private let maxDuration: Double = 1.5

    func manualAdd(amount: Int, at location: CGPoint, bottomY: CGFloat) {
        doManualAdd(remaining: amount, at: location, bottomY: bottomY)
    }

    private func doManualAdd(
        remaining: Int,
        at location: CGPoint,
        bottomY: CGFloat
    ) {
        guard let underlying = underlyingMolecules else {
            return
        }
        guard underlying.canEmitMolecule() && remaining > 0 else {
            return
        }
        doAdd(at: location, bottomY: bottomY)
        let nextDelay = Double.random(in: 0.05...0.1)
        DispatchQueue.main.asyncAfter(deadline: .now() + nextDelay) { [weak self] in
            self?.doManualAdd(remaining: remaining - 1, at: location, bottomY: bottomY)
        }
    }

    func doAdd(
        at location: CGPoint,
        bottomY: CGFloat
    ) {
        guard let underlying = underlyingMolecules else {
            return
        }
        guard underlying.canEmitMolecule() else {
            return
        }

        let newIndex = underlying.molecules.endIndex
        let molecule = MovingPoint(position: location)
        underlying.molecules.append(molecule)

        let dy = bottomY - location.y
        let duration = min(maxDuration, Double(dy) / velocity)
        let finalPosition = CGPoint(x: molecule.position.x, y: bottomY)

        withAnimation(.linear(duration: duration)) {
            underlying.molecules[newIndex].position = finalPosition
        }

        underlying.didEmitMolecules(count: 1)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.moleculeHasHitWater(id: molecule.id)
        }
    }

    private func moleculeHasHitWater(id: UUID) {
        guard let underlying = underlyingMolecules else {
            return
        }
        if let index = underlying.molecules.firstIndex(where: { $0.id == id }) {
            underlying.molecules.remove(at: index)
        }
        underlying.addMolecules(count: 1)
    }
}
