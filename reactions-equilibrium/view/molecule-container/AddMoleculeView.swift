//
// Reactions App
//


import SwiftUI

struct AddMoleculesView: View {

    let model: AddingMoleculesViewModel
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
        AddMoleculeContainerView(
            model: model.models.value(for: molecule),
            isActive: activeMoleculeBinding(molecule: molecule),
            initialLocation: CGPoint(
                x: containerX(width: width, index: index),
                y: height / 5
            ),
            containerWidth: containerWidth,
            startOfWater: startOfWater,
            maxContainerY: maxContainerY,
            moleculeSize: moleculeSize,
            moleculeColor: molecule.color,
            imageName: molecule.imageName
        )
        .zIndex(activeMolecule == molecule ? 1 : 0)
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
                let dy = drag.location.y - initialLocation.y
                offset = CGSize(
                    width: drag.location.x - initialLocation.x,
                    height: min(dy, maxYOffset)
                )
                let effectivePosition = CGPoint(
                    x: initialLocation.x + offset.width,
                    y: initialLocation.y + offset.height
                )
                model.add(at: effectivePosition, to: startOfWater + (moleculeSize / 2))
            }.onEnded { _ in
                withAnimation(.spring()) {
                    offset = .zero
                    rotation = .zero
                }
            })
    }

    private var maxYOffset: CGFloat {
        maxContainerY - initialLocation.y
    }
}

class AddingMoleculesViewModel {

    let canAddMolecule: () -> Bool
    let addMolecules: (AqueousMolecule, Int) -> Void

    init(canAddMolecule: @escaping () -> Bool, addMolecules: @escaping (AqueousMolecule, Int) -> Void) {
        self.canAddMolecule = canAddMolecule
        self.addMolecules = addMolecules

        func model(_ molecule: AqueousMolecule) -> AddingSingleMoleculeViewModel{
            AddingSingleMoleculeViewModel(
                canAddMolecule: canAddMolecule,
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
    private let timeBetweenDrops = 0.15
    private let velocity = 4.0 // pts per second

    /// Adds a molecule at the start position, and animates the Y value to endY
    func add(
        at startPosition: CGPoint,
        to endY: CGFloat
    ) {
        guard canAddMolecule() else {
            return
        }
        guard lastDrop == nil || Date().timeIntervalSince(lastDrop!) >= timeBetweenDrops else {
            return
        }
        lastDrop = Date()

        let molecule = FallingMolecule(position: startPosition)
        molecules.append(molecule)

        let dy = endY / startPosition.y
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

    private func moleculeHasHitWater(id: UUID) {
        if let index = molecules.firstIndex(where: { $0.id == id }) {
            molecules.remove(at: index)
        }
        addMolecules(1)
    }
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
                        canAddMolecule: { true },
                        addMolecules: { (_, _) in }
                    ),
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
