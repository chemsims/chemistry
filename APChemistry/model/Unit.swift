//
// Reactions App
//

import Foundation

enum Unit: String, Identifiable {
    case reactionRates,
         equilibrium,
         acidsBases,
         chenmicalReactions

    /// The available units the user can choose from
    static let available: [Unit] = [.reactionRates, .equilibrium, .acidsBases]


    var id: String {
        self.rawValue
    }

    var info: UnitInfo {
        switch self {
        case .reactionRates: return .reactionRates
        case .equilibrium: return .equilibrium
        case .acidsBases: return .acidsBases
        case .chemicalReactions: return .chemicalReactions
        }
    }
}

struct UnitInfo {
    let image: String
    let title: String
    let description: String
}

extension UnitInfo {

    fileprivate static let reactionRates = UnitInfo(
        image: "reaction-rates-icon",
        title: "Reaction Rates",
        description: "Reaction rates and rate laws."
    )

    fileprivate static let equilibrium = UnitInfo(
        image: "equilibrium-icon",
        title: "Equilibrium",
        description: """
        Reactions which move towards equilibrium.
        """
    )

    fileprivate static let acidsBases = UnitInfo(
        image: "acidsbases-icon",
        title: "Acids & Bases",
        description: "Acid & base reactions."
    )

    fileprivate static let chemicalReactions = UnitInfo(
        image: "reaction-rates-icon",
        title: "Chemical Reactions",
        description: "Chemical reactions."
    )
}
