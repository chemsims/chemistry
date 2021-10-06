//
// Reactions App
//

import SwiftUI
import ReactionsCore

// TODO - split this up a little. The precipitate could be taken out into its own view
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

    @GestureState private var precipitateOffset: CGSize = .zero

    var body: some View {
        ZStack(alignment: .top) {
            scales

            VStack(spacing: 0) {
                Spacer(minLength: 0)
                beaker
            }

            containers
                .mask(
                    VStack(spacing: 0) {
                        Rectangle()
                            .frame(
                                size: layout.containerAreaMask(
                                    rows: model.rows
                                )
                            )
                        Spacer(minLength: 0)
                    }
                )
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
            activeToolTipText: { _ in nil }
        )
        .frame(width: layout.common.totalBeakerAreaWidth)
    }

    private var scales: some View {
        let mass = components.productMass.getY(at: components.reactionProgress).str(decimals: 2)
        return DigitalScales(
            label: model.precipitatePosition == .scales ? "\(mass) g" : nil,
            layout: layout.scalesLayout,
            emphasise: model.precipitatePosition != .scales && precipitateIsOverlappingScales(offset: precipitateOffset)
        )
        .position(layout.scalesPosition)
    }

    private var beaker: some View {
        VStack(alignment: .trailing, spacing: 0) {
            beakers
            selectionToggle
        }
    }

    private var beakers: some View {
        ZStack(alignment: .bottom) {
            precipitate
                .zIndex(model.beakerView == .macroscopic ? 1 : 0)

            microscopicBeaker
            if model.beakerView == .macroscopic {
                macroBeaker
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
            beakerColorMultiply: .white,
            sliderColorMultiply: .white,
            beakerModifier: IdentityViewModifier()
        )
    }

    private var macroBeaker: some View {
        let waterHeight = layout.common.waterHeight(rows: model.rows)
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
    }

    private var precipitate: some View {
        Polygon(points: components.precipitate.points)
            .foregroundColor(PrecipitationComponents.Molecule.product.color(reaction: model.chosenReaction))
            .frame(
                width: layout.common.innerBeakerWidth,
                height: layout.common.waterHeight(rows: model.rows)
            )
            .position(model.precipitatePosition == .scales ? layout.scalesPosition : layout.precipitatePositionInBeaker(rows: model.rows))
            .offset(precipitateOffset)
            .gesture(
                DragGesture().updating($precipitateOffset) { (gesture, offsetState, _) in
                    guard model.input == .weighProduct else {
                        return
                    }
                    offsetState = gesture.translation
                }.onEnded { gesture in
                    guard model.input == .weighProduct else {
                        return
                    }
                    let isOverlapping = precipitateIsOverlappingScales(offset: gesture.translation)
                    if isOverlapping {
                        model.precipitatePosition = .scales
                    } else {
                        model.precipitatePosition = .beaker
                    }
                })
            .animation(.easeOut(duration: 0.25), value: precipitateOffset)
            .animation(.easeOut(duration: 0.25), value: model.precipitatePosition)
    }

    // A rect surrounding the precipitate, without accounting for drag offset.
    // we have the rect using relative points between 0 and 1, in the reference of the containing shape.
    // i.e., when precipitate is in water, then 0,0 is the top left of the water, and 1,1 is the
    // bottom right.
    // We need to convert the relative points into absolute coordinates, and then change
    // the frame of reference so we are measuring the origin from the parent view, rather than
    // the containing shape.
    private var precipitateRect: CGRect {
        let baseRect = components.precipitate.boundingRect

        let shapeWidth = layout.common.innerBeakerWidth
        let shapeHeight = layout.common.waterHeight(rows: model.rows)

        let scaledSize = CGSize(
            width: shapeWidth * baseRect.size.width,
            height: shapeHeight * baseRect.size.height
        )

        // Distance of precipitate rect origin from the shape origin (top left of the shape, not the center)
        let scaledOriginInShape = CGPoint(
            x: shapeWidth * baseRect.origin.x,
            y: shapeHeight * baseRect.origin.y
        )

        let shapeCenterFromParentView = precipitatePosition
        let shapeOriginFromCenter = CGPoint(x: -shapeWidth / 2, y: -shapeHeight / 2)

        // If you draw out these origins out as lines, it is clearer that we need to sum each 3
        // components. Imagine we are at the parent origin, we first move to the shape
        // center. We then move to the shape origin, and finally to the precipitate rect origin.
        let newOrigin = CGPoint(
            x: shapeCenterFromParentView.x + shapeOriginFromCenter.x + scaledOriginInShape.x,
            y: shapeCenterFromParentView.y + shapeOriginFromCenter.y + scaledOriginInShape.y
        )

        return CGRect(origin: newOrigin, size: scaledSize)
    }

    private var precipitatePosition: CGPoint {
        model.precipitatePosition == .scales ? layout.scalesPosition : layout.precipitatePositionInBeaker(rows: model.rows)
    }

    private func precipitateIsOverlappingScales(offset: CGSize) -> Bool {
        let offsetRect = precipitateRect.offsetBy(dx: offset.width, dy: offset.height)
        return offsetRect.intersects(layout.scalesRect)
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
                    label: "" // TODO
                ),
                fractionToDraw: coords.fractionToDraw
            )
        }
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
