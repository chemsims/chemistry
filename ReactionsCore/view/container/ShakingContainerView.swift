//
// Reactions App
//


import SwiftUI

public struct ShakingContainerView: View {

    /// Creates a ShakingContainerView instance.
    ///
    /// - Parameters:
    ///     - includeContainerBackground: Whether to include a background
    ///     behind the container. This is useful to highlight the container for example.
    ///
    public init(
        model: ShakeContainerViewModel,
        position: CoreMotionPositionViewModel,
        onTap: @escaping (CGPoint) -> Void,
        initialLocation: CGPoint,
        containerWidth: CGFloat,
        containerSettings: ParticleContainerSettings,
        moleculeSize: CGFloat,
        moleculeColor: Color,
        includeContainerBackground: Bool,
        rotation: Angle,
        toolTipText: TextLine? = nil
    ) {
        self.model = model
        self.position = position
        self.onTap = onTap
        self.initialLocation = initialLocation
        self.containerWidth = containerWidth
        self.containerSettings = containerSettings
        self.moleculeSize = moleculeSize
        self.moleculeColor = moleculeColor
        self.includeContainerBackground = includeContainerBackground
        self.rotation = rotation
        self.toolTipText = toolTipText
    }

    @ObservedObject var model: ShakeContainerViewModel
    @ObservedObject var position: CoreMotionPositionViewModel

    let onTap: (CGPoint) -> Void
    let initialLocation: CGPoint
    let containerWidth: CGFloat
    let containerSettings: ParticleContainerSettings
    let moleculeSize: CGFloat
    let moleculeColor: Color
    let includeContainerBackground: Bool
    let rotation: Angle
    let toolTipText: TextLine?

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
            if let toolTipText = toolTipText {
                toolTip(text: toolTipText)
            }
        }
    }

    private var container: some View {
        ParticleContainer(settings: containerSettings)
            .animation(nil)
            .rotationEffect(rotation)
            .frame(width: containerWidth)
            .background(
                Color.white
                    .padding(-0.15 * containerWidth).opacity(includeContainerBackground ? 1 : 0)
            )
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

    private func toolTip(text: TextLine) -> some View {
        let width = 2 * containerWidth
        let height = containerWidth
        return Tooltip(
            text: text,
            fontSize: 1.5 * containerSettings.labelFontSize,
            arrowPosition: .bottom,
            arrowLocation: .inside
        )
        .frame(width: width, height: height)
        .position(initialLocation)
        .offset(offset)
        .offset(y: -0.75 * containerHeight)
    }

    private var offset: CGSize {
        CGSize(
            width: (position.xOffset + simulatorOffset.0) * halfXRange,
            height: (position.yOffset + simulatorOffset.1) * halfYRange
        )
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

    private var halfXRange: CGFloat {
        model.halfXRange ?? 0
    }

    private var halfYRange: CGFloat {
        model.halfYRange ?? 0
    }

    private var containerHeight: CGFloat {
        ParticleContainer.heightToWidth * containerWidth
    }

    private var isSimulator: Bool {
    #if targetEnvironment(simulator)
        return true
    #else
        return false
    #endif
    }
}
