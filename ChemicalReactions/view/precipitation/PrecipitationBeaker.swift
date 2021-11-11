//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct PrecipitationBeaker: View {

    init(model: PrecipitationScreenViewModel, layout: PrecipitationScreenLayout) {
        self.model = model
        self.components = model.components
        self.shakeModel = model.shakeModel
        self.layout = layout
    }

    @ObservedObject var model: PrecipitationScreenViewModel
    @ObservedObject var components: PrecipitationComponents
    @ObservedObject var shakeModel: MultiContainerShakeViewModel<PrecipitationComponents.Reactant>
    let layout: PrecipitationScreenLayout

    @GestureState var precipitateOffset: CGSize = .zero

    var body: some View {
        ZStack(alignment: .top) {
            scales
                .colorMultiply(model.highlights.colorMultiply(for: nil))

            VStack(spacing: 0) {
                Spacer(minLength: 0)
                beaker
            }
            .zIndex(model.input == .weighProduct ? 1 : 0)

            containers
                .mask(
                    VStack(spacing: 0) {
                        Rectangle()
                            .frame(size: layout.containerAreaMask(rows: model.rows))
                            .offset(y: -layout.containerAreaMaskOffset)
                        Spacer(minLength: 0)
                    }
                )

            // We must wrap add z-index to the group for transition to work
            Group {
                if showMovingHand {
                    movingHand
                        .transition(.opacity.animation(.easeOut(duration: 0.25)))
                        .accessibility(hidden: true)
                }
            }
            .zIndex(2)

        }
        .frame(width: layout.common.totalBeakerAreaWidth, height: layout.common.beakerAreaHeight)
    }

    private var containers: some View {
        MultiShakingContainerView(
            shakeModel: shakeModel,
            containerPosition: {
                layout.common.initialContainerPosition(index: $0.index)
            },
            activeContainerPosition: { _ in
                layout.common.activeContainerPosition
            },
            disabled: {
                model.input != .addReactant(type: $0)
            },
            containerWidth: layout.common.containerWidth,
            containerSettings: {
                $0.containerSettings(reaction: model.chosenReaction, layout: layout.common)
            },
            moleculeSize: layout.common.containerMoleculeSize,
            topOfWaterY: layout.topOfWaterPosition(rows: model.rows),
            halfXShakeRange: layout.common.containerShakeHalfXRange,
            halfYShakeRange: layout.common.containerShakeHalfYRange,
            highlightedMolecule: highlightedReactant,
            dismissHighlight: { model.highlights.clear() },
            activeToolTipText: containerToolTip
        )
        .frame(width: layout.common.totalBeakerAreaWidth)
    }

    private var highlightedReactant: PrecipitationComponents.Reactant? {
        let elements = model.highlights.elements
        if elements.contains(.knownReactantContainer) {
            return .known
        } else if elements.contains(.unknownReactantContainer) {
            return .unknown
        }
        return nil
    }

    private func containerToolTip(reactant: PrecipitationComponents.Reactant) -> TextLine? {
        if reactant == .unknown {
            let mass = components.unknownReactantMassAdded
            return "\(mass.str(decimals: 2))"
        }
        return nil
    }

    private var scales: some View {
        let massEq = components.productMassProduced
        let progress = components.reactionProgress
        let mass = massEq.getY(at: progress).str(decimals: 2)
        let massString = model.precipitatePosition == .scales ? "\(mass) g" : nil
        return DigitalScales(
            label: massString,
            layout: layout.scalesLayout,
            emphasise: shouldEmphasiseScales
        )
        .position(layout.scalesPosition)
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text("Scales showing weight of precipitate"))
        .accessibility(value: Text(massString ?? "empty scales"))
    }

    private var shouldEmphasiseScales: Bool {
        if model.precipitatePosition == .beaker {
            return precipitateGeometry.isOverlappingScales(offset: precipitateOffset)
        }
        return false
    }


    private var beaker: some View {
        VStack(alignment: .trailing, spacing: 0) {
            beakers
            selectionToggle
        }
        .padding(.bottom, layout.common.beakerBottomPadding)
    }

    private var beakers: some View {
        ZStack(alignment: .bottom) {
            precipitate
                .zIndex(model.beakerView == .macroscopic ? 1 : 0)

            microscopicBeaker
                .accessibility(hidden: model.beakerView == .macroscopic)

            if model.beakerView == .macroscopic {
                macroBeaker
                    .colorMultiply(model.highlights.colorMultiply(for: nil))
            }

            if model.showReRunReactionButton {
                runAgain
            }
        }
        .accessibilityElement(children: .contain)
        .modifier(BeakerActionAccessibilityModifier(model: model))
    }

    private var runAgain: some View {
        VStack(spacing: 0) {
            
            Button(action: model.runReactionAgain) {
                ZStack {
                    RoundedRectangle(cornerRadius: layout.runAgainButtonCornerRadius)
                        .foregroundColor(.gray.opacity(0.1))
                    Text("Run again?")
                        .foregroundColor(.orangeAccent)
                }
                .frame(size: layout.runAgainButtonSize)
            }
            .padding(.top, layout.runAgainButtonTopPadding)

            Spacer()
        }
        .frame(
            width: layout.common.beakerSettings.beakerWidth,
            height: layout.common.beakerSettings.beakerHeight
        )
        .font(.system(size: layout.runAgainFontSize))
        .minimumScaleFactor(0.5)
        .horizontalSpacing(alignment: .trailing)
    }

    private var precipitate: some View {
        PolygonEquationShape(
            points: components.precipitate.points,
            progress: components.reactionProgress
        )
        .foregroundColor(model.chosenReaction.product.color)
        .padding(.bottom, model.precipitatePosition == .beaker ? 2 : 0)
        .frame(size: layout.precipitateShapeSize(rows: model.rows))
        .position(precipitateGeometry.position)
        .offset(precipitateOffset)
        .gesture(dragGesture)
        .animation(.easeOut(duration: 0.25), value: precipitateOffset)
        .animation(.easeOut(duration: 0.25), value: model.precipitatePosition)
    }

    private var dragGesture: some Gesture {
        DragGesture().updating($precipitateOffset) { (gesture, offsetState, _) in
            guard model.input == .weighProduct else {
                return
            }
            offsetState = precipitateGeometry.limitedOffset(translation: gesture.translation)
        }
        .onEnded { gesture in
            guard model.input == .weighProduct else {
                return
            }
            let limitedOffset = precipitateGeometry.limitedOffset(translation: gesture.translation)
            let isOverlapping = precipitateGeometry.isOverlappingScales(offset: limitedOffset)
            if isOverlapping {
                model.precipitatePosition = .scales
                model.didWeighProduct()
            } else {
                model.precipitatePosition = .beaker
            }
        }
    }

    private var microscopicBeaker: some View {
        AdjustableFluidBeaker(
            rows: $model.rows,
            molecules: [],
            animatingMolecules: animatingMolecules,
            currentTime: components.reactionProgress,
            settings: layout.common.beakerSettings,
            canSetLevel: model.input == .setWaterLevel,
            beakerColorMultiply: model.highlights.colorMultiply(for: nil),
            sliderColorMultiply: model.highlights.colorMultiply(for: .waterSlider),
            beakerModifier: IdentityViewModifier()
        )
    }

    private var macroBeaker: some View {
        let waterHeight = layout.common.waterHeight(rows: model.rows)
        let percentage = components.reactionProgress.percentage
        return FillableBeaker(
            waterColor: Styling.beakerLiquid,
            waterHeight: waterHeight,
            highlightBeaker: true,
            settings: layout.fillableBeakerSettings
        ) {
            EmptyView()
        }
        .padding(.leading, layout.common.beakerSettings.sliderSettings.handleWidth)
        .frame(width: layout.common.totalBeakerAreaWidth)
        .accessibility(label: Text("Beaker of liquid with a solid precipitate"))
        .accessibility(value: Text("Precipitate is \(percentage) of it's final size"))
    }

    private var selectionToggle: some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            SelectionToggleText(
                text: "Microscopic",
                isSelected: model.beakerView == .microscopic,
                action: { model.beakerView = .microscopic }
            )
            Spacer(minLength: 0)
            SelectionToggleText(
                text: "Macroscopic",
                isSelected: model.beakerView == .macroscopic,
                action: { model.beakerView = .macroscopic }
            )
            Spacer(minLength: 0)
        }
        .font(.system(size: layout.beakerToggleFontSize))
        .frame(
            width: layout.common.beakerSettings.beakerWidth,
            height: layout.beakerToggleTextHeight
        )
        .disabled(model.beakerToggleIsDisabled)
        .colorMultiply(model.highlights.colorMultiply(for: nil))
    }

    private var movingHand: some View {
        MovingHand(
            initialPosition: precipitateGeometry.precipitateRect.center,
            finalPosition: layout.scalesPosition,
            handWidth: layout.handWidth
        )
    }

    // don't show the hand when user starts dragging precipitate
    private var showMovingHand: Bool {
        model.showMovingHand && precipitateOffset == .zero
    }

    private func containerPos(reactant: PrecipitationComponents.Reactant, isActive: Bool) -> CGPoint {
        .zero
    }

    private var animatingMolecules: [AnimatingBeakerMolecules] {
        PrecipitationComponents.Molecule.allCases.map { molecule in
            let coords = components.coords(for: molecule)
            return AnimatingBeakerMolecules(
                molecules: BeakerMolecules(
                    coords: coords.coordinates,
                    color: molecule.color(reaction: model.chosenReaction),
                    label: molecule.name(reaction: model.chosenReaction).label
                ),
                fractionToDraw: coords.fractionToDraw
            )
        }
    }

    private var precipitateGeometry: PrecipitateGeometry {
        PrecipitateGeometry(
            model: model,
            components: components,
            layout: layout
        )
    }
}

private extension PrecipitationComponents.Reactant {
    var index: Int {
        Self.allCases.firstIndex(of: self) ?? -1
    }

    func containerSettings(
        reaction: PrecipitationReaction,
        layout: ChemicalReactionsScreenLayout
    ) -> ParticleContainerSettings {
        ParticleContainerSettings(
            labelColor: self.molecule.color(reaction: reaction),
            label: self.molecule.name(reaction: reaction),
            labelFontSize: layout.containerFontSize,
            labelFontColor: .white,
            strokeLineWidth: layout.containerLineWidth
        )
    }
}

fileprivate struct PrecipitateGeometry {
    let model: PrecipitationScreenViewModel
    let components: PrecipitationComponents
    let layout: PrecipitationScreenLayout

    func isOverlappingScales(offset: CGSize) -> Bool {
        let offsetRect = precipitateRect.offsetBy(dx: offset.width, dy: offset.height)
        return offsetRect.intersects(layout.scalesRect)
    }

    func limitedOffset(translation: CGSize) -> CGSize {
        let maxWidthOffset = layout.precipitateMaxDragX - position.x
        let limitedWidth = min(translation.width, maxWidthOffset)
        return CGSize(width: limitedWidth, height: translation.height)
    }

    var position: CGPoint {
        if model.precipitatePosition == .scales {
            return positionOnScales
        }
        return layout.precipitatePositionInBeaker(rows: model.rows)
    }

    /// A rect surrounding the precipitate, without accounting for drag offset.
    /// we have the rect using relative points between 0 and 1, in the reference of the containing shape.
    /// i.e., when precipitate is in water, then 0,0 is the top left of the water, and 1,1 is the
    /// bottom right.
    /// We need to convert the relative points into absolute coordinates, and then change
    /// the frame of reference so we are measuring the origin from the parent view, rather than
    /// the containing shape.
    var precipitateRect: CGRect {
        let boundingRect = scaledBoundingRect

        let shapeCenterFromParentView = position
        let shapeOriginFromCenter = CGPoint(x: -shapeWidth / 2, y: -shapeHeight / 2)

        // If you draw out these origins out as lines, it is clearer
        // that we need to sum each 3 components. Imagine we are at
        // the parent origin, we first move to the center. We then
        // move to the shape origin, and finally to the precipitate
        // rect origin.
        let newOrigin = CGPoint(
            x: shapeCenterFromParentView.x + shapeOriginFromCenter.x + boundingRect.origin.x,
            y: shapeCenterFromParentView.y + shapeOriginFromCenter.y + boundingRect.origin.y
        )

        return CGRect(origin: newOrigin, size: boundingRect.size)
    }

    /// We want the bottom of the `bounding` rect to be on top of the weighing scales area
    private var positionOnScales: CGPoint {
        let topOfWeighingAreaFromTopOfScales = layout.scalesLayout.topOfWeighingArea
        let topOfWeighingAreaFromCenterOfScales = topOfWeighingAreaFromTopOfScales - (layout.scalesLayout.height / 2)

        // the position in the frame of reference of the containing view
        // i.e. same FOR as containers & beakers for example
        let topOfWeighingAreaPosition = layout.scalesPosition.offset(dx: 0, dy: topOfWeighingAreaFromCenterOfScales)

        let boundingRect = scaledBoundingRect

        // returning `topOfWeighingAreaPosition` would place the center of the shape
        // containing the precipitate, at the top of the weighing area. Since we want the bottom
        // of the bounding rect, we must offset by the distance between the center of the
        // shape, and the bottom of the precipitate in the shape.
        let deltaY = (shapeHeight / 2) - boundingRect.maxY

        return topOfWeighingAreaPosition.offset(dx: 0, dy: deltaY)
    }

    // A rect surrounding the precipitate, in the frame of reference of the shape containing
    // the precipitate. The rect is scaled into absolute values, rather than fractional values.
    private var scaledBoundingRect: CGRect {
        let baseRect = components.precipitate.boundingRect(at: components.reactionProgress)
        let scaledSize = CGSize(
            width: shapeWidth * baseRect.size.width,
            height: shapeHeight * baseRect.size.height
        )

        // Distance of precipitate rect origin from the shape origin (top left of the shape, not the center)
        let scaledOriginInShape = CGPoint(
            x: shapeWidth * baseRect.origin.x,
            y: shapeHeight * baseRect.origin.y
        )

        return CGRect(origin: scaledOriginInShape, size: scaledSize)
    }

    private var shapeSize: CGSize {
        layout.precipitateShapeSize(rows: model.rows)
    }

    private var shapeHeight: CGFloat {
        shapeSize.height
    }

    private var shapeWidth: CGFloat {
        shapeSize.width
    }
}

private struct BeakerActionAccessibilityModifier: ViewModifier {

    @ObservedObject var model: PrecipitationScreenViewModel

    func body(content: Content) -> some View {
        content
            .modifyIf(UIAccessibility.isVoiceOverRunning) {
                $0
                    .modifier(BeakerAddReactantModifier(model: model, reactant: .known))
                    .modifier(BeakerAddReactantModifier(model: model, reactant: .unknown))
                    .modifier(BeakerWeighProductModifier(model: model))
            }
    }
}

private struct BeakerAddReactantModifier: ViewModifier {

    @ObservedObject var model: PrecipitationScreenViewModel
    let reactant: PrecipitationComponents.Reactant

    func body(content: Content) -> some View {
        content
            .modifyIf(model.input == .addReactant(type: reactant)) {
                $0
                    .accessibilityAction(named: Text("Add 5 \(name) molecules"), { model.add(reactant: reactant, count: 5) } )
                    .accessibilityAction(named: Text("Add 15 \(name) molecules"), { model.add(reactant: reactant, count: 15) } )
            }
    }

    private var name: String {
        switch reactant {
        case .known: return model.chosenReaction.knownReactant.name.label
        case .unknown: return model.chosenReaction.unknownReactant.name(showMetal: false).label
        }
    }
}

private struct BeakerWeighProductModifier: ViewModifier {
    @ObservedObject var model: PrecipitationScreenViewModel

    func body(content: Content) -> some View {
        content
            .modifyIf(model.input == .weighProduct) {
                $0.accessibilityAction(named: Text("Weigh precipitate"), model.accessibilityWeighProductAction)
            }

    }
}
