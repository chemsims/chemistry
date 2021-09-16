//
// Reactions App
//

import ReactionsCore
import SwiftUI

struct LimitingReagentBeaker: View {

    @ObservedObject var shakeModel: MultiContainerShakeViewModel<LimitingReagentComponents.Reactant>
    let layout: LimitingReagentScreenLayout

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                beaker
            }

            containers 
        }
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
        let model = shakeModel.model(for: reactant)
        let isActive = shakeModel.activeMolecule == reactant
        let location = layout.common.containerPosition(index: reactant.index, active: isActive)

        return ShakingContainerView(
            model: model,
            position: model.motion.position,
            onTap: { loc in didTap(reactant: reactant, location: loc) },
            initialLocation: location,
            containerWidth: layout.common.containerWidth,
            containerSettings: .init(
                labelColor: .red,
                label: "\(reactant.rawValue)",
                labelFontSize: layout.common.containerFontSize,
                labelFontColor: .white,
                strokeLineWidth: 1
            ),
            moleculeSize: layout.common.containerMoleculeSize,
            moleculeColor: .red,
            includeContainerBackground: false,
            rotation: isActive ? .degrees(135) : .zero
        )
    }

    private var beaker: some View {
        AdjustableFluidBeaker(
            rows: .constant(10),
            molecules: [],
            animatingMolecules: [],
            currentTime: 0,
            settings: layout.common.beakerSettings,
            canSetLevel: true,
            beakerColorMultiply: .white,
            sliderColorMultiply: .white,
            beakerModifier: IdentityViewModifier()
        )
    }

    private func didTap(reactant: LimitingReagentComponents.Reactant, location: CGPoint) {
        
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
                shakeModel: .init(
                    canAddMolecule: { _ in true },
                    addMolecules: { _, _ in },
                    useBufferWhenAddingMolecules: false
                ),
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
