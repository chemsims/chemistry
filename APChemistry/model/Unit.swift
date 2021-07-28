//
// Reactions App
//

import Foundation

enum Unit: String, Identifiable {
    case reactionRates,
         equilibrium,
        acidsBases

    static var all: [Unit] = [.reactionRates, .equilibrium, .acidsBases]

    var id: String {
        self.rawValue
    }

    var inAppPurchaseID: String? {
        switch self {
        case .equilibrium: return "equilibrium_unit"
        case .acidsBases: return "acid_bases_unit"
        default: return nil
        }
    }

    var info: UnitInfo {
        switch self {
        case .reactionRates: return .reactionRates
        case .equilibrium: return .equilibrium
        case .acidsBases: return .acidsBases
        }
    }
}

struct UnitInfo {
    let image: String
    let title: String
    let description: String
}

extension UnitInfo {

    static let all: [Unit] = [.reactionRates, .equilibrium]

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
}
