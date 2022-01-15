//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AddMoleculesView: View {

    @ObservedObject var model: MultiContainerShakeViewModel<AqueousMolecule>
    let inputState: AqueousReactionInputState
    let topRowHeight: CGFloat
    let containerWidth: CGFloat
    let containerHeight: CGFloat
    let startOfWater: CGFloat
    let moleculeSize: CGFloat
    let topRowColorMultiply: Color?
    let onDrag: () -> Void
    let showShakeText: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let manualAddAmount = 5

    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .foregroundColor(.white)
                .frame(height: 1.1 * containerHeight)
                .position(x: geometry.size.width / 2, y: topRowHeight)
                .colorMultiply(topRowColorMultiply ?? .white)

            container(molecule: .A, width: geometry.size.width, height: geometry.size.height, index: 0)
            container(molecule: .B, width: geometry.size.width, height: geometry.size.height, index: 1)
            container(molecule: .C, width: geometry.size.width, height: geometry.size.height, index: 2)
            container(molecule: .D, width: geometry.size.width, height: geometry.size.height, index: 3)
        }
        .accessibilityElement(children: .contain)
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
            position: model.models.value(for: molecule).motion.position,
            onTap: { loc in
                didTap(
                    molecule: molecule,
                    width: width,
                    height: height,
                    index: index,
                    bottomY: startOfWater + (moleculeSize / 2),
                    location: loc
                )
            },
            width: width,
            height: height,
            initialLocation: getLocation(for: molecule, width: width, index: index),
            containerWidth: containerWidth,
            moleculeSize: moleculeSize,
            moleculeColor: molecule.color,
            imageName: molecule.imageName,
            rotation: model.activeMolecule == molecule ? .degrees(135) : .zero
        )
        .zIndex(model.activeMolecule == molecule ? 1 : 0)
        .disabled(!isActive)
        .colorMultiply(isActive ? .white : Styling.inactiveContainerMultiply)
        .accessibility(removeTraits: .isImage)
        .accessibility(addTraits: .isButton)
        .accessibility(label: Text("Container of molecule \(molecule.rawValue)"))
        .accessibility(hint: Text(getContainerHint(molecule: molecule)))
        .accessibility(sortPriority: Double(10 - index))
    }

    private func getContainerHint(molecule: AqueousMolecule) -> String {
        if model.activeMolecule == molecule {
            return "Adds \(manualAddAmount) molecules of \(molecule) to the beaker"
        }
        return "Prepares molecule \(molecule) to add to beaker"
    }

    private func getLocation(for molecule: AqueousMolecule, width: CGFloat, index: Int) -> CGPoint {
        if model.activeMolecule == molecule {
            return CGPoint(
                x: width / 2,
                y: topRowHeight + (0.75 * containerHeight)
            )
        }
        return CGPoint(x: containerX(width: width, index: index), y: topRowHeight)
    }

    private func containerX(width: CGFloat, index: Int) -> CGFloat {
        let spacing = (width - (4 * containerWidth)) / 5
        let initial = spacing + (containerWidth / 2)
        let extra = CGFloat(index) * (spacing + containerWidth)
        return initial + extra
    }

    private func didTap(
        molecule: AqueousMolecule,
        width: CGFloat,
        height: CGFloat,
        index: Int,
        bottomY: CGFloat,
        location: CGPoint
    ) {
        guard model.activeMolecule != molecule else {
            manualAdd(molecule: molecule, amount: manualAddAmount, location: location)
            return
        }
        
        withAnimation(.easeOut(duration: 0.25)) {
            model.activeMolecule = molecule
            showShakeText()
        }
        model.start(
            for: molecule,
            at: getLocation(
                for: molecule,
                width: width, 
                index: index
            ),
            bottomY: startOfWater + (moleculeSize / 2),
            halfXRange: width / 2,
            halfYRange: containerHeight
        )
        onDrag()
    }

    private func manualAdd(molecule: AqueousMolecule, amount: Int, location: CGPoint) {
        model.models.value(for: molecule).manualAdd(amount: amount, at: location)
    }
}

// TODO - replace this with `ShakingContainerView`
private struct AddMoleculeContainerView: View {

    @ObservedObject var model: ShakeContainerViewModel
    @ObservedObject var position: CoreMotionPositionViewModel

    let onTap: (CGPoint) -> Void
    let width: CGFloat
    let height: CGFloat
    let initialLocation: CGPoint
    let containerWidth: CGFloat
    let moleculeSize: CGFloat
    let moleculeColor: Color
    let imageName: String
    let rotation: Angle

    @GestureState private var simulatorOffset: (CGFloat, CGFloat) = (0, 0)

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
        Image(imageName, bundle: .equilibrium)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .rotationEffect(rotation)
            .frame(width: containerWidth)
            .position(initialLocation)
            .offset(offset)
            .onTapGesture {
                let location = initialLocation.offset(offset)
                onTap(location)
            }
            .modifyIf(isSimulator) {
                $0.gesture(simulatorDragGesture)
            }
    }

    private var offset: CGSize {
        CGSize(
            width: (position.xOffset + simulatorOffset.0) * halfXRange,
            height: (position.yOffset + simulatorOffset.1) * halfYRange
        )
    }

    private var isSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }

    private var simulatorDragGesture: some Gesture {
        DragGesture().updating($simulatorOffset) { gesture, offset, _ in
            let w = gesture.translation.width
            let h = gesture.translation.height

            let newY = LinearEquation(x1: -halfYRange, y1: -1, x2: halfYRange, y2: 1).getValue(at: h).within(min: -1, max: 1)
            let newX = LinearEquation(x1: -halfXRange, y1: -1, x2: halfXRange, y2: 1).getValue(at: w).within(min: -1, max: 1)

            offset.0 = newX
            offset.1 = newY
        }
    }

    private var halfXRange: CGFloat {
        model.halfXRange ?? 0
    }

    private var halfYRange: CGFloat {
        model.halfYRange ?? 0
    }
}

struct AddMoleculeView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                AddMoleculesView(
                    model: MultiContainerShakeViewModel(
                        canAddMolecule: { _ in true },
                        addMolecules: { (_, _) in },
                        useBufferWhenAddingMolecules: false
                    ),
                    inputState: .addProducts,
                    topRowHeight: 50,
                    containerWidth: 50,
                    containerHeight: 115,
                    startOfWater: geo.size.height - 150,
                    moleculeSize: 25,
                    topRowColorMultiply: nil,
                    onDrag: {},
                    showShakeText: {}
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
