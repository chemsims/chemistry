//
// Reactions App
//


import SwiftUI

public struct ShakingContainerView: View {

    public init(
        model: ShakeContainerViewModel,
        position: CoreMotionPositionViewModel,
        onTap: @escaping () -> Void,
        initialLocation: CGPoint,
        containerWidth: CGFloat,
        containerSettings: ParticleContainerSettings,
        moleculeSize: CGFloat,
        moleculeColor: Color,
        rotation: Angle,
        halfXRange: CGFloat,
        halfYRange: CGFloat,
        isSimulator: Bool
    ) {
        self.model = model
        self.position = position
        self.onTap = onTap
        self.initialLocation = initialLocation
        self.containerWidth = containerWidth
        self.containerSettings = containerSettings
        self.moleculeSize = moleculeSize
        self.moleculeColor = moleculeColor
        self.rotation = rotation
        self.halfXRange = halfXRange
        self.halfYRange = halfYRange
        self.isSimulator = isSimulator
    }


    @ObservedObject var model: ShakeContainerViewModel
    @ObservedObject var position: CoreMotionPositionViewModel

    let onTap: () -> Void
    let initialLocation: CGPoint
    let containerWidth: CGFloat
    let containerSettings: ParticleContainerSettings
    let moleculeSize: CGFloat
    let moleculeColor: Color
    let rotation: Angle
    let halfXRange: CGFloat
    let halfYRange: CGFloat
    let isSimulator: Bool

    @GestureState private var simulatorOffset: (CGFloat, CGFloat) = (0, 0)


    public var body: some View {
        ZStack {
            ForEach(model.molecules) { molecule in
                Circle()
                    .foregroundColor(moleculeColor)
                    .frame(
                        width: moleculeSize,
                        height: moleculeSize
                    )
                    .position(molecule.position)
            }

            container
        }
    }

    private var container: some View {
        ParticleContainer(settings: containerSettings)
            .rotationEffect(rotation)
            .frame(width: containerWidth)
            .position(initialLocation)
            .offset(
                CGSize(
                    width: (position.xOffset + simulatorOffset.0) * halfXRange,
                    height: (position.yOffset + simulatorOffset.1) * halfYRange
                )
            )
            .onTapGesture {
                onTap()
            }
            .modifyIf(isSimulator) {
                $0.gesture(simulatorDragGesture)
            }
    }

    private var simulatorDragGesture: some Gesture {
        DragGesture().updating($simulatorOffset) { gesture, offset, _ in
            let w = gesture.translation.width
            let h = gesture.translation.height

            let newY = LinearEquation(x1: -halfYRange, y1: -1, x2: halfYRange, y2: 1).getY(at: h).within(min: -1, max: 1)
            let newX = LinearEquation(x1: -halfXRange, y1: -1, x2: halfXRange, y2: 1).getY(at: w).within(min: -1, max: 1)

            offset.0 = newX
            offset.1 = newY
        }
    }
}
