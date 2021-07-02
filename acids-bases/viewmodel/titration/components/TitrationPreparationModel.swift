//
// Reactions App
//

import Foundation
import ReactionsCore

protocol TitrationPreparationModel {
    var hasAddedEnoughSubstance: Bool { get }
    var canAddSubstance: Bool { get }

    var titrant: Titrant { get }

    func resetState()
}

extension TitrationStrongSubstancePreparationModel: TitrationPreparationModel {
    func resetState() {
        substanceAdded = 0
        primaryIonCoords.coords.removeAll()
        reactionProgress = reactionProgress.copy(withCounts: .constant(0))
    }
}

extension TitrationWeakSubstancePreparationModel: TitrationPreparationModel {
    func resetState() {
        substanceAdded = 0
        reactionProgress = 0
        substanceCoords.coords.removeAll()
    }
}
