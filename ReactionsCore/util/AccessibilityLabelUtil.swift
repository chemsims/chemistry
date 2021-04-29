//
// Reactions App
//

import Foundation

struct AccessibilityLabelUtil {
    private init() { }

    static func beakerGridLabel(
        molecules: [BeakerMolecules],
        animatingMolecules: [AnimatingBeakerMolecules],
        fluid: String
    ) -> String {
        if let moleculeString = moleculeLabelString(
            molecules: molecules,
            animatingMolecules: animatingMolecules
        ) {
            return "Beaker showing a grid of molecules of \(moleculeString) in \(fluid)"
        }

        return "Beaker showing an empty grid of molecules"
    }

    static func moleculeLabelString(
        molecules: [BeakerMolecules],
        animatingMolecules: [AnimatingBeakerMolecules]
    ) -> String? {
        let labels = molecules.map(\.label) + animatingMolecules.map(\.molecules.label)
        let sortedLabels = labels.sorted()
        if sortedLabels.isEmpty {
            return nil
        }
        return StringUtil.combineStringsWithFinalAnd(sortedLabels)
    }
}
