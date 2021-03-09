//
// Reactions App
//

import SwiftUI
import ReactionsCore

class AddingMoleculesViewModel {

    let canAddMolecule: (AqueousMolecule) -> Bool
    let addMolecules: (AqueousMolecule, Int) -> Void

    init(canAddMolecule: @escaping (AqueousMolecule) -> Bool, addMolecules: @escaping (AqueousMolecule, Int) -> Void) {
        self.canAddMolecule = canAddMolecule
        self.addMolecules = addMolecules

        func model(_ molecule: AqueousMolecule) -> AddingSingleMoleculeViewModel{
            AddingSingleMoleculeViewModel(
                canAddMolecule: { canAddMolecule(molecule) },
                addMolecules: { addMolecules(molecule, $0) }
            )
        }

        self.models = MoleculeValue(builder: model)
    }


    let models: MoleculeValue<AddingSingleMoleculeViewModel>

}

class AddingSingleMoleculeViewModel: ObservableObject {

    let canAddMolecule: () -> Bool
    let addMolecules: (Int) -> Void

    init(canAddMolecule: @escaping () -> Bool, addMolecules: @escaping (Int) -> Void) {
        self.canAddMolecule = canAddMolecule
        self.addMolecules = addMolecules
    }

    @Published var molecules = [FallingMolecule]()

    private var lastDrop: Date?
    private let velocity = 200.0 // pts per second

    @Published var lastAddAttempt: (CGPoint, Date)?

    /// Adds a molecule at the start position, and animates the Y value to endY
    func add(
        at startPosition: CGPoint,
        to endY: CGFloat,
        time: Date
    ) {

        let timeBetweenDrops = getTimeIntervalBetweenDrops(startPosition: startPosition, currentTime: time)
        guard canAddMolecule() else {
            return
        }
        guard lastDrop == nil || Date().timeIntervalSince(lastDrop!) >= Double(timeBetweenDrops) else {
            return
        }
        lastDrop = Date()

        let molecule = FallingMolecule(position: startPosition)
        molecules.append(molecule)

        let dy = endY - startPosition.y
        let duration = Double(dy) / velocity

        withAnimation(.linear(duration: duration)) {
            molecules[molecules.count - 1].position = CGPoint(x: startPosition.x, y: endY)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.moleculeHasHitWater(id: molecule.id)
        }
    }

    /// Removes all falling molecules, and calls the molecule was added function
    func removeAllMolecules() {
        let count = molecules.count
        molecules.removeAll()
        addMolecules(count)
    }


    private func handleVelocityCheck(position: CGPoint) {
        let now = Date()
        if let lastAttempt = lastAddAttempt {
            let dx = abs(position.x - lastAttempt.0.x)
            let dy = abs(position.y - lastAttempt.0.y)
            let magChange = sqrt(pow(dx, 2) + pow(dy, 2))
            let dt = now.timeIntervalSince(lastAttempt.1)

            let vSquared = magChange / CGFloat(dt)
            print(vSquared)
        }
        lastAddAttempt = (position, now)
    }

    private func getTimeIntervalBetweenDrops(
        startPosition: CGPoint,
        currentTime: Date
    ) -> CGFloat {
        let velocity = getVelocity(currentPosition: startPosition, currentTime: currentTime)
        self.lastAddAttempt = (startPosition, currentTime)
        return AddingMoleculesSettings.getTimeInterval(velocity: velocity)
    }

    private func getVelocity(
        currentPosition: CGPoint,
        currentTime: Date
    ) -> CGFloat? {
        lastAddAttempt.map { lastAttempt in
            let dx = currentPosition.x - lastAttempt.0.x
            let dy = currentPosition.y - lastAttempt.0.y

            let distance = sqrt(pow(dx, 2) + pow(dy, 2))
            let dt = currentTime.timeIntervalSince(lastAttempt.1)

            return distance / CGFloat(dt)
        }
    }


    private func moleculeHasHitWater(id: UUID) {
        if let index = molecules.firstIndex(where: { $0.id == id }) {
            molecules.remove(at: index)
        }
        addMolecules(1)
    }
}

private struct AddingMoleculesSettings {

    static func getTimeInterval(velocity: CGFloat?) -> CGFloat {
        velocity.map { v in
            min(maxTimeInterval, max(minTimeInterval, equation.getY(at: v)))
        } ?? maxTimeInterval
    }

    private static let minTimeInterval: CGFloat = 0.02
    private static let maxTimeInterval: CGFloat = 0.2
    private static let minVelocity: CGFloat = 100
    private static let maxVelocity: CGFloat = 500

    private static let equation = LinearEquation(
        x1: minVelocity,
        y1: maxTimeInterval,
        x2: maxVelocity,
        y2: minTimeInterval
    )

}
