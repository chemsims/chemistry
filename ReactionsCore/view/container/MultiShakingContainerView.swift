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
        highlightedMolecule: Molecule? = nil,
        dismissHighlight: @escaping () -> Void = { },
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
        self.highlightedMoleculeContainer = highlightedMolecule
        self.dismissHighlight = dismissHighlight
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
    let highlightedMoleculeContainer: Molecule?
    let dismissHighlight: () -> Void
    let activeToolTipText: (Molecule) -> TextLine?

    public var body: some View {
        ZStack {
            ForEach(Array(Molecule.allCases)) { molecule in
                container(molecule: molecule)
            }
        }
        .accessibilityElement(children: .contain)
    }

    private let manualAddAmount = 5

    private func container(molecule: Molecule) -> some View {
        let containerModel = shakeModel.model(for: molecule)
        let isActive = shakeModel.activeMolecule == molecule
        let location = isActive ? activeContainerPosition(molecule) : containerPosition(molecule)
        let isDisabled = disabled(molecule)
        let toolTipText = isActive ? activeToolTipText(molecule) : nil

        let label = containerSettings(molecule).label.label
        let accessibilityLabel = "Container of \(label)"

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
            containerColorMultiply: containerColorMultiply(for: molecule),
            moleculeColorMultiply: moleculeColorMultiply(for: molecule),
            includeContainerBackground: highlightedMoleculeContainer == molecule,
            rotation: isActive ? .degrees(135) : .zero,
            toolTipText: toolTipText
        )
        .disabled(isDisabled)
        .zIndex(isActive ? 1 : 0)
        .minimumScaleFactor(0.4)
        .accessibility(addTraits: .isButton)
        .accessibility(label: Text(accessibilityLabel))
        .accessibility(hint: Text(getContainerHint(molecule)))
        .accessibility(sortPriority: moleculeSortPriority(molecule))
    }

    private func getContainerHint(_ molecule: Molecule) -> String {
        if shakeModel.activeMolecule == molecule {
            let label = containerSettings(molecule).label.label
            return "Adds \(manualAddAmount) molecules of \(label) to the beaker"
        }
        return "Prepares container to add to beaker"
    }

    private func containerColorMultiply(for molecule: Molecule) -> Color {
        if shouldDimContainer(for: molecule) {
            return Styling.inactiveContainerMultiply
        }
        return .white
    }

    private func moleculeColorMultiply(for molecule: Molecule) -> Color {
        if shouldDimMolecule(for: molecule) {
            return Styling.inactiveContainerMultiply
        }
        return .white
    }

    // We only want to dim falling molecules when we're highlighting
    // another container.
    private func shouldDimMolecule(for molecule: Molecule) -> Bool {
        if let highlightedMolecule = highlightedMoleculeContainer {
            return molecule != highlightedMolecule
        }
        return false
    }

    // We dim the container when highlighting another molecule, or
    // if its disabled
    private func shouldDimContainer(for molecule: Molecule) -> Bool {
        shouldDimMolecule(for: molecule) || disabled(molecule)
    }

    private func onTap(molecule: Molecule, location: CGPoint) {
        if shakeModel.activeMolecule == molecule {
            let model = shakeModel.model(for: molecule)
            model.manualAdd(amount: manualAddAmount, at: location)
            return
        }
        dismissHighlight()
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

    // We give an explicit sort priority to molecules, so their ordering is
    // not changed when one moves to the active location. The ordering we use
    // is the same as the allCases order (but in descending numbers as the
    // highest priority shows up first)
    private func moleculeSortPriority(_ molecule: Molecule) -> Double {
        guard let index = Molecule.allCases.firstIndex(of: molecule) else {
            return 0
        }
        let firstIndex = Molecule.allCases.startIndex
        let countFromFirst = Molecule.allCases.distance(from: firstIndex, to: index)
        return Double(Molecule.allCases.count - countFromFirst)

    }
}
