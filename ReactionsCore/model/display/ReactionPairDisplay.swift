//
// ReactionsCore
//

import SwiftUI

public struct ReactionPairDisplay {
    public let reactant: ReactionMoleculeDisplay
    public let product: ReactionMoleculeDisplay
}

public struct ReactionMoleculeDisplay {
    public let name: String
    public let color: Color
}
