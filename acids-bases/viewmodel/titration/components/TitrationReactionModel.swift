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

extension TitrationStrongSubstancePreEPModel: TitrationReactionModel {
}

extension TitrationStrongSubstancePostEPModel: TitrationReactionModel {
}

extension TitrationWeakSubstancePreEPModel: TitrationReactionModel {
}

extension TitrationWeakSubstancePostEPModel: TitrationReactionModel {
}

extension PrimaryIon {
    var concentration: TitrationEquationTerm.Concentration {
        switch self {
        case .hydrogen: return .hydrogen
        case .hydroxide: return .hydroxide
        }
    }
}
