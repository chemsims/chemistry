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
            activeToolTipText: containerToolTip
        )
        .frame(width: layout.common.totalBeakerAreaWidth)
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
        return DigitalScales(
            label: model.precipitatePosition == .scales ? "\(mass) g" : nil,
            layout: layout.scalesLayout,
            emphasise:shouldEmphasiseScales
        )
        .position(layout.scalesPosition)
    }

    private var shouldEmphasiseScales: Bool {
        return false
//        if model.precipitatePosition == .scales {
//            return false
//        }
//        return precipitateGeometry.isOverlappingScales(offset: precipitateOffset)
    }

    private var beaker: some View {
        VStack(alignment: .trailing, spacing: 0) {
            beakers
            selectionToggle
        }
    }

    private var beakers: some View {
        ZStack(alignment: .bottom) {
            PrecipitateBeakerDeposit(
                model: model,
                components: components,
                layout: layout
            )
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
