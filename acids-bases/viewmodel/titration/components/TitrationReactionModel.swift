//
// Reactions App
//

import Foundation
import ReactionsCore

protocol TitrationReactionModel: ObservableObject {
    func incrementTitrant(count: Int)

    var titrantAdded: Int { get }

    var maxTitrant: Int { get }

    var pH: Equation { get }
}

protocol TitrantInputModel {
    var maxTitrant: Int { get }
    var titrantAdded: Int { get }
}

extension TitrantInputModel {
    var canAddTitrant: Bool {
        titrantCountAvailable > 0
    }

    var hasAddedEnoughTitrant: Bool {
        !canAddTitrant
    }

    var titrantCountAvailable: Int {
        max(0, maxTitrant - titrantAdded)
    }
}

extension TitrationStrongSubstancePreEPModel: TitrationReactionModel, TitrantInputModel {
}

extension TitrationStrongSubstancePostEPModel: TitrationReactionModel, TitrantInputModel {
}

extension TitrationWeakSubstancePreEPModel: TitrationReactionModel, TitrantInputModel {
}

extension TitrationWeakSubstancePostEPModel: TitrationReactionModel, TitrantInputModel {
}

extension PrimaryIon {
    var concentration: TitrationEquationTerm.Concentration {
        switch self {
        case .hydrogen: return .hydrogen
        case .hydroxide: return .hydroxide
        }
    }
}
