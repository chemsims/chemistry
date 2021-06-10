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
    let onTap: () -> Void
    let initialLocation: CGPoint
    let type: ContainerType
    let label: String
    let color: Color
    let rows: CGFloat
    let disabled: Bool

    var body: some View {
        let addModel = models.model(for: type)
        let isActive = models.activeMolecule == type

        return ShakingContainerView(
            model: addModel,
            position: addModel.motion.position,
            onTap: onTap,
            initialLocation: initialLocation,
            containerWidth: layout.containerSize.width,
            containerSettings: ParticleContainerSettings(
                labelColor: color,
                label: label,
                labelFontColor: .white,
                strokeLineWidth: 0.4
            ),
            moleculeSize: layout.moleculeSize,
            moleculeColor: color,
            rotation: isActive ? .degrees(135) : .zero,
            isSimulator: AcidBasesApp.isSimulator
        )
        .font(.system(size: layout.containerFontSize))
        .minimumScaleFactor(0.1)
        .zIndex(isActive ? 1 : 0)
        .disabled(disabled)
        .colorMultiply(disabled ? Styling.inactiveContainerMultiply : .white)
        .mask(
            VStack(spacing: 0) {
                Rectangle()
                    .frame(
                        width: layout.beakerWidth + (2 * layout.containerSize.height),
                        height: layout.topOfWaterPosition(rows: rows)
                    )
                Spacer()
            }
        )
    }
}
