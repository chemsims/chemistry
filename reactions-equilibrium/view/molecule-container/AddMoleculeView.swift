//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AddMoleculesView: View {

    @ObservedObject var shakeModel: NewAddingSingleMoleculeViewModel
    let model: AddingMoleculesViewModel
    let inputState: AqueousReactionInputState
    let topRowHeight: CGFloat
    let containerWidth: CGFloat
    let containerHeight: CGFloat
    let startOfWater: CGFloat
    let maxContainerY: CGFloat
    let moleculeSize: CGFloat
    let topRowColorMultiply: Color?
    let onDrag: () -> Void

    init(
        model: AddingMoleculesViewModel,
        inputState: AqueousReactionInputState,
        topRowHeight: CGFloat,
        containerWidth: CGFloat,
        containerHeight: CGFloat,
        startOfWater: CGFloat,
        maxContainerY: CGFloat,
        moleculeSize: CGFloat,
        topRowColorMultiply: Color?,
        onDrag: @escaping () -> Void
    ) {
        self.model = model
        self.shakeModel = model.newModel
        self.inputState = inputState
        self.topRowHeight = topRowHeight
        self.containerWidth = containerWidth
        self.containerHeight = containerHeight
        self.startOfWater = startOfWater
        self.maxContainerY = maxContainerY
        self.moleculeSize = moleculeSize
        self.topRowColorMultiply = topRowColorMultiply
        self.onDrag = onDrag
    }


    @State private var activeMolecule: AqueousMolecule?

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
            newModel: shakeModel,
            onDrag: {
                didDrag(
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
            startOfWater: startOfWater,
            maxContainerY: maxContainerY,
            moleculeSize: moleculeSize,
            moleculeColor: molecule.color,
            imageName: molecule.imageName,
            rotation: activeMolecule == molecule ? .degrees(135) : .zero
        )
        .zIndex(activeMolecule == molecule ? 1 : 0)
        .disabled(!isActive)
        .colorMultiply(isActive ? .white : Color.gray.opacity(0.5))
    }

    private func getLocation(for molecule: AqueousMolecule, width: CGFloat, index: Int) -> CGPoint {
        if activeMolecule == molecule {
            return CGPoint(
                x: width / 2 + shakeModel.xOffset,
                y: topRowHeight + (1.5 * containerHeight) + shakeModel.yOffset
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

    private func didDrag(
        molecule: AqueousMolecule,
        width: CGFloat,
        height: CGFloat,
        index: Int,
        bottomY: CGFloat
    ) {
        withAnimation(.easeOut(duration: 0.25)) {
            activeMolecule = molecule
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

    @ObservedObject var model: AddingSingleMoleculeViewModel
    @ObservedObject var newModel: NewAddingSingleMoleculeViewModel

    let onDrag: () -> Void
    let width: CGFloat
    let height: CGFloat
    let initialLocation: CGPoint
    let containerWidth: CGFloat
    let startOfWater: CGFloat
    let maxContainerY: CGFloat
    let moleculeSize: CGFloat
    let moleculeColor: Color
    let imageName: String
    let rotation: Angle

    @State private var offset = CGSize.zero
//    @State private var rotation = Angle.zero

    var body: some View {
        ZStack {
            ForEach(newModel.molecules) { molecule in
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
            .onTapGesture {
                onDrag()
            }
//            .gesture(DragGesture().onChanged { drag in
//                onDrag()
//                withAnimation(.easeOut(duration: 0.25)) {
//                    rotation = .degrees(135)
//                }
//                offset = CGSize(
//                    width: constrainedXOffset(offset: drag.location.x - initialLocation.x),
//                    height: constrainedYOffset(offset: drag.location.y - initialLocation.y)
//                )
//                let effectivePosition = CGPoint(
//                    x: initialLocation.x + offset.width,
//                    y: initialLocation.y + offset.height
//                )
////                model.add(at: effectivePosition, to: startOfWater + (moleculeSize / 2), time: drag.time)
//                newModel.moved(to: effectivePosition, endY: startOfWater + (moleculeSize / 2))
//            }.onEnded { _ in
//                endDrag()
//            })
            .onReceive(
                NotificationCenter.default.publisher(
                    for: UIApplication.willResignActiveNotification
                )
            ) { _ in
                endDrag()
            }
    }

    private func endDrag() {
        withAnimation(.spring()) {
            offset = .zero
//            rotation = .zero
        }
        model.endDrag()
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
                    maxContainerY: geo.size.height - 300,
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
