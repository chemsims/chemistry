//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AddMoleculesView: View {

    let model: AddingMoleculesViewModel
    let inputState: AqueousReactionInputState
    let topRowHeight: CGFloat
    let containerWidth: CGFloat
    let startOfWater: CGFloat
    let maxContainerY: CGFloat
    let moleculeSize: CGFloat

    @State private var activeMolecule = AqueousMolecule.A

    var body: some View {
        GeometryReader { geometry in
            container(molecule: .A, width: geometry.size.width, height: geometry.size.height, index: 0)
            container(molecule: .B, width: geometry.size.width, height: geometry.size.height, index: 1)
            container(molecule: .C, width: geometry.size.width, height: geometry.size.height, index: 2)
            container(molecule: .D, width: geometry.size.width, height: geometry.size.height, index: 3)
        }
    }

    private func container(
        molecule: AqueousMolecule,
        width: CGFloat,
        height: CGFloat,
        index: Int
    ) -> some View {
        let activeProduct = molecule.isProduct && inputState == .addProducts
        let activeReactant = molecule.isReactant && inputState == .addReactants
        let isActive = activeProduct || activeReactant
        return AddMoleculeContainerView(
            model: model.models.value(for: molecule),
            isActive: activeMoleculeBinding(molecule: molecule),
            width: width,
            height: height,
            initialLocation: CGPoint(
                x: containerX(width: width, index: index),
                y: topRowHeight
            ),
            containerWidth: containerWidth,
            startOfWater: startOfWater,
            maxContainerY: maxContainerY,
            moleculeSize: moleculeSize,
            moleculeColor: molecule.color,
            imageName: molecule.imageName
        )
        .zIndex(activeMolecule == molecule ? 1 : 0)
        .disabled(!isActive)
        .colorMultiply(isActive ? .white : Color.gray.opacity(0.5))
    }

    private func containerX(width: CGFloat, index: Int) -> CGFloat {
        let spacing = (width - (4 * containerWidth)) / 5
        let initial = spacing + (containerWidth / 2)
        let extra = CGFloat(index) * (spacing + containerWidth)
        return initial + extra
    }

    private func activeMoleculeBinding(molecule: AqueousMolecule) -> Binding<Bool> {
        Binding(
            get: { activeMolecule == molecule },
            set: {
                if $0 {
                    activeMolecule = molecule
                }
            }
        )
    }
}

private struct AddMoleculeContainerView: View {

    @ObservedObject var model: AddingSingleMoleculeViewModel
    @Binding var isActive: Bool
    let width: CGFloat
    let height: CGFloat
    let initialLocation: CGPoint
    let containerWidth: CGFloat
    let startOfWater: CGFloat
    let maxContainerY: CGFloat
    let moleculeSize: CGFloat
    let moleculeColor: Color
    let imageName: String

    @State private var offset = CGSize.zero
    @State private var rotation = Angle.zero

    var body: some View {
        ZStack {
            ForEach(model.molecules) { molecule in
                Circle()
                    .foregroundColor(moleculeColor)
                    .frame(width: moleculeSize, height: moleculeSize)
                    .position(molecule.position)
            }
            image
        }
    }

    private var image: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .rotationEffect(rotation)
            .frame(width: containerWidth)
            .position(initialLocation)
            .offset(offset)
            .gesture(DragGesture().onChanged { drag in
                isActive = true
                withAnimation(.easeOut(duration: 0.25)) {
                    rotation = .degrees(135)
                }
                offset = CGSize(
                    width: constrainedXOffset(offset: drag.location.x - initialLocation.x),
                    height: constrainedYOffset(offset: drag.location.y - initialLocation.y)
                )
                let effectivePosition = CGPoint(
                    x: initialLocation.x + offset.width,
                    y: initialLocation.y + offset.height
                )
                model.add(at: effectivePosition, to: startOfWater + (moleculeSize / 2), time: drag.time)
            }.onEnded { _ in
                withAnimation(.spring()) {
                    offset = .zero
                    rotation = .zero
                }
            })
    }

    private var maxYOffset: CGFloat {
        min(maxContainerY, height) - initialLocation.y
    }

    private func constrainedYOffset(offset: CGFloat) -> CGFloat {
        let maxDy = min(maxContainerY, height) - initialLocation.y
        let minDy = -initialLocation.y
        return min(maxDy, max(minDy, offset))
    }

    private func constrainedXOffset(offset: CGFloat) -> CGFloat {
        let maxDx = width - initialLocation.x
        let minDx = -initialLocation.x
        return min(maxDx, max(minDx, offset))
    }
}

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
        print(timeBetweenDrops)
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

struct FallingMolecule: Identifiable {
    let id = UUID()
    var position: CGPoint
}

struct AddMoleculeView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                AddMoleculesView(
                    model: AddingMoleculesViewModel(
                        canAddMolecule: { _ in true },
                        addMolecules: { (_, _) in }
                    ),
                    inputState: .addProducts,
                    topRowHeight: 50,
                    containerWidth: 50,
                    startOfWater: geo.size.height - 150,
                    maxContainerY: geo.size.height - 300,
                    moleculeSize: 25
                )

                Rectangle()
                    .frame(height: 1)
                    .position(x: geo.size.width / 2, y: geo.size.height - 300)

                Rectangle()
                    .frame(height: 150)
                    .opacity(0.5)
                    .position(x: geo.size.width / 2, y: geo.size.height - 75)
            }.frame(height: geo.size.height)
        }
    }
}
