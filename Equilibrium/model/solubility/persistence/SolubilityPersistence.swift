//
// Reactions App
//

import Foundation

protocol SolubilityPersistence {
    var reaction: SolubleReactionType? { get set }
}

class InMemorySolubilityPersistence: SolubilityPersistence {
    var reaction: SolubleReactionType?
}
