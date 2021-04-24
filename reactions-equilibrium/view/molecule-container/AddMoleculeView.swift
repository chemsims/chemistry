//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AddMoleculesView: View {

    @ObservedObject var model: AddingMoleculesViewModel
    let inputState: AqueousReactionInputState
    let topRowHeight: CGFloat
    let containerWidth: CGFloat
    let containerHeight: CGFloat
    let startOfWater: CGFloat
    let moleculeSize: CGFloat
    let topRowColorMultiply: Color?
    let onDrag: () -> Void

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
            onTap: {
                didTap(
                    molecule: molecule,
                    width: width,
                    height: height,
                    index: index,
                    bottomY: startOfWater + (moleculeSize / 2)
                )
            },
            width: width,
            height: height,
            initialLocation: getLocation(for: molecule, width: width, index: index),
            containerWidth: containerWidth,
            moleculeSize: moleculeSize,
            moleculeColor: molecule.color,
            imageName: molecule.imageName,
            rotation: model.activeMolecule == molecule ? .degrees(135) : .zero,
            halfXRange: width / 2,
            halfYRange: containerHeight
        )
        .zIndex(model.activeMolecule == molecule ? 1 : 0)
        .disabled(!isActive)
        .colorMultiply(isActive ? .white : Color.gray.opacity(0.5))
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
        bottomY: CGFloat
    ) {
        guard model.activeMolecule != molecule else {
            model.models.value(for: molecule).manualAdd()
            return
        }
        
        withAnimation(.easeOut(duration: 0.25)) {
            model.activeMolecule = molecule
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
}

private struct AddMoleculeContainerView: View {

    @ObservedObject var model: ShakeContainerViewModel
    @ObservedObject var position: CoreMotionPositionViewModel

    let onTap: () -> Void
    let width: CGFloat
    let height: CGFloat
    let initialLocation: CGPoint
    let containerWidth: CGFloat
    let moleculeSize: CGFloat
    let moleculeColor: Color
    let imageName: String
    let rotation: Angle

    let halfXRange: CGFloat
    let halfYRange: CGFloat

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
            .offset(
                CGSize(
                    width: position.xOffset * halfXRange,
                    height: position.yOffset * halfYRange
                )
            )
            .onTapGesture {
                onTap()
            }
    }

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
                    containerHeight: 115,
                    startOfWater: geo.size.height - 150,
                    moleculeSize: 25,
                    topRowColorMultiply: nil,
                    onDrag: {}
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
