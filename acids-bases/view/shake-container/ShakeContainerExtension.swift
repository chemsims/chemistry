//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AcidAppShakingContainerView<ContainerType>: View
where ContainerType : CaseIterable, ContainerType : Hashable
{

    @ObservedObject var models: MultiContainerShakeViewModel<ContainerType>
    let layout: AcidBasesScreenLayout
    let initialLocation: CGPoint
    let activeLocation: CGPoint
    let type: ContainerType
    let label: TextLine
    let color: Color
    let topOfWaterPosition: CGFloat
    let disabled: Bool
    let onActivateContainer: (ContainerType) -> Void

    var body: some View {
        let addModel = models.model(for: type)
        let isActive = models.activeMolecule == type

        return ShakingContainerView(
            model: addModel,
            position: addModel.motion.position,
            onTap: { didTapContainer(type) },
            initialLocation: isActive ? activeLocation : initialLocation,
            containerWidth: layout.containerSize.width,
            containerSettings: ParticleContainerSettings(
                labelColor: color,
                label: label,
                labelFontSize: layout.containerFontSize,
                labelFontColor: .white,
                strokeLineWidth: 0.4
            ),
            moleculeSize: layout.moleculeSize,
            moleculeColor: color,
            rotation: isActive ? .degrees(135) : .zero,
            isSimulator: AcidBasesApp.isSimulator
        )
        .minimumScaleFactor(0.1)
        .zIndex(isActive ? 1 : 0)
        .disabled(disabled)
        .colorMultiply(disabled ? Styling.inactiveContainerMultiply : .white)
        .mask(
            VStack(spacing: 0) {
                Rectangle()
                    .frame(
                        width: layout.beakerWidth + (2 * layout.containerSize.height),
                        height: topOfWaterPosition
                    )
                Spacer()
            }
        )
    }

    private func didTapContainer(
        _ element: ContainerType
    ) {
        guard models.activeMolecule != element else {
            models.model(for: element).manualAdd(amount: 5)
            return
        }

        withAnimation(.easeOut(duration: 0.25)) {
            models.activeMolecule = element
            onActivateContainer(element)
        }
        models.start(
            for: element,
            at: activeLocation,
            bottomY: topOfWaterPosition + (layout.moleculeSize / 2),
            halfXRange: layout.containerShakeHalfXRange,
            halfYRange: layout.containerShakeHalfYRange
        )
    }
}
