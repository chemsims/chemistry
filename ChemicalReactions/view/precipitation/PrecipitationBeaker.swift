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

    @State private var showMicroscopicView: Bool = true

    var body: some View {
        ZStack(alignment: .top) {
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
        .frame(height: layout.common.beakerAreaHeight)
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
            activeToolTipText: { reactant in
                if reactant == .unknown {
                    let mass = components.unknownReactantMass.str(decimals: 2)
                    return "\(mass)g"
                }
                return nil
            }
        )
        .frame(width: layout.common.totalBeakerAreaWidth)
    }

    private var beaker: some View {
        VStack(alignment: .trailing, spacing: 0) {
            if showMicroscopicView {
                microscopicBeaker
            } else {
                macroBeaker
            }
            selectionToggle
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
            Rectangle()
                .frame(height: waterHeight)
        }
        .padding(.leading, layout.common.beakerSettings.sliderSettings.handleWidth)
        .frame(width: layout.common.totalBeakerAreaWidth)
    }

    private var selectionToggle: some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            SelectionToggleText(
                text: "Microscopic",
                isSelected: showMicroscopicView,
                action: { showMicroscopicView = true }
            )
            Spacer(minLength: 0)
            SelectionToggleText(
                text: "Macroscopic",
                isSelected: !showMicroscopicView,
                action: { showMicroscopicView = false }
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
