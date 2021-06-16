//
// Reactions App
//

import Foundation

open class ReactionProgressChartViewModelDelegate<MoleculeType> {
    func willMoveMoleculeToTopOfColumn(withId id: UUID) { }

    func willFadeOutBottomMolecules(ofTypes types: [MoleculeType]) { }

    func willSlideColumnsDown(ofTypes types: [MoleculeType]) { }

    func willAddMoleculeToTopOfColumn(ofTypes types: [MoleculeType]) { }
}
