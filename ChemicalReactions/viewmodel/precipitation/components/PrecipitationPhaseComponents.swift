//
// Reactions App
//

import CoreGraphics
import ReactionsCore

protocol PhaseComponents {
    func coords(for molecule: PrecipitationComponents.Molecule) -> FractionedCoordinates

    func canAdd(reactant: PrecipitationComponents.Reactant) -> Bool

    func hasAddedEnough(of reactant: PrecipitationComponents.Reactant) -> Bool

    mutating func add(reactant: PrecipitationComponents.Reactant, count: Int)

    var startOfReaction: CGFloat { get }

    var endOfReaction: CGFloat { get }

    var previouslyReactingUnknownReactantMoles: CGFloat { get }
}
