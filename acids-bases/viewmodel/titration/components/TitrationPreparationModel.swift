//
// Reactions App
//

import Foundation
import ReactionsCore

protocol TitrationPreparationModel {
    var hasAddedEnoughSubstance: Bool { get }
    var canAddSubstance: Bool { get }
}

extension TitrationStrongSubstancePreparationModel: TitrationPreparationModel {
}

extension TitrationWeakSubstancePreparationModel: TitrationPreparationModel {
}
