//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AcidAppShakingContainerView: View {

    @ObservedObject var models: MultiContainerShakeViewModel<AcidOrBaseType>
    let layout: AcidBasesScreenLayout
    let onTap: () -> Void
    let initialLocation: CGPoint
    let type: AcidOrBaseType
    let substance: AcidOrBase?

    var body: some View {
        let addModel = models.model(for: type)
        let isActive = models.activeMolecule == type
        let label = substance?.name ?? ""
        let color = substance?.color ?? RGB.placeholderContainer.color

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
        .minimumScaleFactor(0.7)
        .zIndex(isActive ? 1 : 0)
    }

}
