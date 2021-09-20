//
// Reactions App
//

import ReactionsCore
import SwiftUI

struct LimitingReagentBeaker: View {

    init(model: LimitingReagentScreenViewModel, layout: LimitingReagentScreenLayout) {
        self.model = model
        self.components = model.components
        self.shakeModel = model.shakeReactantModel
        self.layout = layout
    }

    @ObservedObject var model: LimitingReagentScreenViewModel
    @ObservedObject var components: LimitingReagentComponents
    @ObservedObject var shakeModel: MultiContainerShakeViewModel<LimitingReagentComponents.Reactant>
    let layout: LimitingReagentScreenLayout

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
                                width: layout.common.containerMaskWidth,
                                height: layout.common.containerAreaHeight(rows: components.rows)
                            )
                        Spacer(minLength: 0)
                    }
                )
        }
        .frame(height: layout.common.beakerAreaHeight)
    }

    private var containers: some View {
        ZStack {
            ForEach(LimitingReagentComponents.Reactant.allCases) { reactant in
                container(reactant: reactant)
            }
        }
        .frame(width: layout.common.totalBeakerAreaWidth)
    }

    private func container(reactant: LimitingReagentComponents.Reactant) -> some View {
        let containerModel = shakeModel.model(for: reactant)
        let isActive = shakeModel.activeMolecule == reactant
        let location = layout.common.containerPosition(index: reactant.index, active: isActive)

        let disabled = model.input != .addReactant(type: reactant)

        return ShakingContainerView(
            model: containerModel,
            position: containerModel.motion.position,
            onTap: { loc in didTap(reactant: reactant, location: loc) },
            initialLocation: location,
            containerWidth: layout.common.containerWidth,
            containerSettings: .init(
                labelColor: .red,
                label: "\(reactant.rawValue)",
                labelFontSize: layout.common.containerFontSize,
                labelFontColor: .white,
                strokeLineWidth: 0.4
            ),
            moleculeSize: layout.common.containerMoleculeSize,
            moleculeColor: .red,
            includeContainerBackground: false,
            rotation: isActive ? .degrees(135) : .zero
        )
        .disabled(disabled)
        .colorMultiply(disabled ? Styling.inactiveContainerMultiply : .white)
        .zIndex(isActive ? 1 : 0)
    }

    private var beaker: some View {
        AdjustableFluidBeaker(
            rows: $components.rows,
            molecules: [
                BeakerMolecules(
                    coords: components.limitingReactantCoords,
                    color: .purple,
                    label: "" // TODO
                ),
                BeakerMolecules(
                    coords: components.excessReactantCoords,
                    color: .red,
                    label: ""
                )
            ],
            animatingMolecules: [],
            currentTime: 0,
            settings: layout.common.beakerSettings,
            canSetLevel: model.input == .setWaterLevel,
            beakerColorMultiply: .white,
            sliderColorMultiply: .white,
            beakerModifier: IdentityViewModifier()
        )
    }

    private func didTap(reactant: LimitingReagentComponents.Reactant, location: CGPoint) {
        if shakeModel.activeMolecule == reactant {
            shakeModel.model(for: reactant).manualAdd(amount: 5, at: location)
            return
        }

        withAnimation(.easeOut(duration: 0.25)) {
            shakeModel.activeMolecule = reactant
        }

        shakeModel.start(
            for: reactant,
            at: layout.common.containerPosition(index: reactant.index, active: true),
            bottomY: layout.common.topOfWaterPosition(rows: components.rows),
            halfXRange: layout.common.containerShakeHalfXRange,
            halfYRange: layout.common.containerShakeHalfYRange
        )
    }
}

private extension LimitingReagentComponents.Reactant {
    var index: Int {
        Self.allCases.firstIndex(of: self) ?? -1
    }
}

struct LimitingReagentBeaker_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            LimitingReagentBeaker(
                model: .init(),
                layout: .init(
                    common: .init(
                        geometry: geo,
                        verticalSizeClass: nil,
                        horizontalSizeClass: nil
                    )
                )
            )
        }
        .previewLayout(.iPhone12ProMaxLandscape)
    }
}
