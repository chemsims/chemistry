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

    var canAddTitrant: Bool { get }
    var hasAddedEnoughTitrant: Bool { get }

    func resetState()
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
    func resetState() {
        titrantAdded = 0
        self.titrantMolecules.coords.removeAll()
        self.reactionProgress = previous.copyReactionProgress()
    }
}

extension TitrationWeakSubstancePreEPModel: TitrationReactionModel, TitrantInputModel {
}

extension TitrationWeakSubstancePostEPModel: TitrationReactionModel, TitrantInputModel {
    func resetState() {
        titrantAdded = 0
        self.ionMolecules = Self.initialIonMolecules(previous: previous)
        self.secondaryMolecules = Self.initialSecondaryMolecules(previous: previous)
        self.reactionProgress = previous.copyReactionProgress()
    }
}

extension PrimaryIon {
    var concentration: TitrationEquationTerm.Concentration {
        switch self {
        case .hydrogen: return .hydrogen
        case .hydroxide: return .hydroxide
        }
    }
}
