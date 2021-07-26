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
    let accessibilityName: String?
    let color: Color
    let topOfWaterPosition: CGFloat
    let disabled: Bool

    /// Whether to include a background behind the container (useful for highlighting purposes)
    let includeContainerBackground: Bool
    let onActivateContainer: (ContainerType) -> Void

    private let manualAddAmount = 5

    var body: some View {
        let addModel = models.model(for: type)
        let isActive = models.activeMolecule == type

        let accessibilityLabel = accessibilityName.map { (name) -> String in
            "container of \(name) molecules"
        } ?? "placeholder container"

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
            includeContainerBackground: includeContainerBackground,
            rotation: isActive ? .degrees(135) : .zero,
            isSimulator: isSimulator
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
        .accessibility(label: Text(accessibilityLabel))
        .accessibility(addTraits: .isButton)
        .accessibility(hint: Text(getContainerHint(type: type, label: accessibilityName)))
    }

    private var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    private func getContainerHint(type: ContainerType, label: String?) -> String {
        if let label = label {
            if models.activeMolecule == type {
                return "Adds \(manualAddAmount) molecules of \(label) to the beaker"
            }
            return "Prepares container to add to beaker"
        }
        return ""
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
        }

        onActivateContainer(element)
        
        models.start(
            for: element,
            at: activeLocation,
            bottomY: topOfWaterPosition + (layout.moleculeSize / 2),
            halfXRange: layout.containerShakeHalfXRange,
            halfYRange: layout.containerShakeHalfYRange
        )
    }
}
