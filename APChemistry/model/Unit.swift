//
// Reactions App
//

import Foundation

enum Unit: String, Identifiable {
    case reactionRates,
         equilibrium

    static var all: [Unit] = [.reactionRates, .equilibrium]

    var id: String {
        self.rawValue
    }

    var inAppPurchaseID: String {
        self.rawValue
    }

    var info: UnitInfo {
        switch self {
        case .reactionRates: return .reactionRates
        case .equilibrium: return .equilibrium
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
        description: "Reaction rates and rate laws"
    )

    fileprivate static let equilibrium = UnitInfo(
        image: "equilibrium-icon",
        title: "Equilibrium",
        description: """
        Reactions which move towards equilibrium.
        """
    )
}
