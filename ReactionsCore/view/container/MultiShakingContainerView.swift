//
// Reactions App
//

import SwiftUI

public struct MultiShakingContainerView<Molecule>: View where Molecule: EnumMappable, Molecule: Identifiable {

    public init(
        shakeModel: MultiContainerShakeViewModel<Molecule>,
        containerPosition: @escaping (Molecule) -> CGPoint,
        activeContainerPosition: @escaping (Molecule) -> CGPoint,
        disabled: @escaping (Molecule) -> Bool,
        containerWidth: CGFloat,
        containerSettings: @escaping (Molecule) -> ParticleContainerSettings,
        moleculeSize: CGFloat,
        topOfWaterY: CGFloat,
        halfXShakeRange: CGFloat,
        halfYShakeRange: CGFloat,
        activeToolTipText: @escaping (Molecule) -> TextLine? = { _ in nil }
    ) {
        self.shakeModel = shakeModel
        self.containerPosition = containerPosition
        self.activeContainerPosition = activeContainerPosition
        self.disabled = disabled
        self.containerWidth = containerWidth
        self.containerSettings = containerSettings
        self.moleculeSize = moleculeSize
        self.topOfWaterY = topOfWaterY
        self.halfXShakeRange = halfXShakeRange
        self.halfYShakeRange = halfYShakeRange
        self.activeToolTipText = activeToolTipText
    }

    @ObservedObject var shakeModel: MultiContainerShakeViewModel<Molecule>
    let containerPosition: (Molecule) -> CGPoint
    let activeContainerPosition: (Molecule) -> CGPoint
    let disabled: (Molecule) -> Bool
    let containerWidth: CGFloat
    let containerSettings: (Molecule) -> ParticleContainerSettings
    let moleculeSize: CGFloat
    let topOfWaterY: CGFloat
    let halfXShakeRange: CGFloat
    let halfYShakeRange: CGFloat
    let activeToolTipText: (Molecule) -> TextLine?

    public var body: some View {
        ZStack {
            ForEach(Array(Molecule.allCases)) { molecule in
                container(molecule: molecule)
            }
        }
    }

    private func container(molecule: Molecule) -> some View {
        let containerModel = shakeModel.model(for: molecule)
        let isActive = shakeModel.activeMolecule == molecule
        let location = isActive ? activeContainerPosition(molecule) : containerPosition(molecule)
        let isDisabled = disabled(molecule)
        let toolTipText = isActive ? activeToolTipText(molecule) : nil

        return ShakingContainerView(
            model: containerModel,
            position: containerModel.motion.position,
            onTap: { loc in
                onTap(molecule: molecule, location: loc)
            },
            initialLocation: location,
            containerWidth: containerWidth,
            containerSettings: containerSettings(molecule),
            moleculeSize: moleculeSize,
            moleculeColor: containerSettings(molecule).labelColor,
            includeContainerBackground: false,
            rotation: isActive ? .degrees(135) : .zero,
            toolTipText: toolTipText
        )
        .disabled(isDisabled)
        .colorMultiply(isDisabled ? Styling.inactiveContainerMultiply : .white)
        .zIndex(isActive ? 1 : 0)
        .minimumScaleFactor(0.4)
    }

    private func onTap(molecule: Molecule, location: CGPoint) {
        if shakeModel.activeMolecule == molecule {
            let model = shakeModel.model(for: molecule)
            model.manualAdd(amount: 5, at: location)
            return
        }

        withAnimation(.easeOut(duration: 0.25)) {
            shakeModel.activeMolecule = molecule
        }

        shakeModel.start(
        for: molecule,
           at: activeContainerPosition(molecule),
           bottomY: topOfWaterY,
           halfXRange: halfXShakeRange,
           halfYRange: halfYShakeRange
        )
    }
}
