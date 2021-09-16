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
    /// 
    /// - Parameter useBufferWhenAddingMolecules: Whether to call `addMolecules` once for any
    /// molecules which hit the water within short buffer window. When false, molecules will be added immediately
    /// when they hit the water. This may cause a performance issue if `addMolecules` is a relatively expensive operation.
    init(
        underlyingMolecules: MoleculeEmittingContainer,
        useBufferWhenAddingMolecules: Bool
    ) {
        self.underlyingMolecules = underlyingMolecules
        self.useBufferWhenAddingMolecules = useBufferWhenAddingMolecules
    }

    weak var underlyingMolecules: MoleculeEmittingContainer?

    private let velocity = 200.0 // pts per second
    private let maxDuration: Double = 1.5

    private let useBufferWhenAddingMolecules: Bool

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

    private let moleculeFlushWindow: TimeInterval = 0.1
    private var addMoleculeBuffer = [UUID]()
    private var addMoleculeTimer: Timer? = nil

    private func moleculeHasHitWater(id: UUID) {
        if useBufferWhenAddingMolecules {
            if addMoleculeTimer == nil {
                addMoleculeTimer = Timer.scheduledTimer(
                    timeInterval: moleculeFlushWindow,
                    target: self,
                    selector: #selector(flushAddMoleculeBuffer),
                    userInfo: nil,
                    repeats: false
                )
            }
            addMoleculeBuffer.append(id)
        } else if let underlying = underlyingMolecules {
            underlying.molecules.removeAll { $0.id == id }
            underlying.addMolecules(count: 1)
        }
    }

    @objc private func flushAddMoleculeBuffer() {
        guard let underlying = underlyingMolecules else {
            return
        }
        underlying.molecules.removeAll { addMoleculeBuffer.contains($0.id) }
        underlying.addMolecules(count: addMoleculeBuffer.count)
        addMoleculeBuffer.removeAll()
        addMoleculeTimer?.invalidate()
        addMoleculeTimer = nil
    }
}
