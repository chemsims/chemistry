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
            disabled: { _ in false },
            containerWidth: layout.common.containerWidth,
            containerSettings: {
                $0.containerSettings(layout: layout.common)
            },
            moleculeSize: layout.common.containerMoleculeSize,
            topOfWaterY: layout.topOfWaterPosition(rows: model.rows),
            halfXShakeRange: layout.common.containerShakeHalfXRange,
            halfYShakeRange: layout.common.containerShakeHalfYRange
        )
        .frame(width: layout.common.totalBeakerAreaWidth)
    }

    private var beaker: some View {
        VStack(alignment: .trailing, spacing: 0) {
            AdjustableFluidBeaker(
                rows: $model.rows,
                molecules: [],
                animatingMolecules: animatingMolecules,
                currentTime: 0,
                settings: layout.common.beakerSettings,
                canSetLevel: true,
                beakerColorMultiply: .white,
                sliderColorMultiply: .white,
                beakerModifier: IdentityViewModifier()
            )
            selectionToggle
        }
    }

    private var selectionToggle: some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            SelectionToggleText(
                text: "Microscopic",
                isSelected: true,
                action: { }
            )
            Spacer(minLength: 0)
            SelectionToggleText(
                text: "Macroscopic",
                isSelected: false,
                action: { }
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
                    color: .red,
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

    func containerSettings(layout: ChemicalReactionsScreenLayout) -> ParticleContainerSettings {
        ParticleContainerSettings(
            labelColor: .red,
            label: "",
            labelFontSize: layout.containerFontSize,
            labelFontColor: .white,
            strokeLineWidth: layout.containerLineWidth
        )
    }
}
