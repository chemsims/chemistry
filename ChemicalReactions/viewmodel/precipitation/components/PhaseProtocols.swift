//
// Reactions App
//

import Foundation
import ReactionsCore

protocol PrecipitationComponentsReactantPreparation {
    func initialCoords(for molecule: PrecipitationComponents.Molecule) -> [GridCoordinate]

    mutating func add(reactant: PrecipitationComponents.Reactant, count: Int)

    func canAdd(reactant: PrecipitationComponents.Reactant) -> Bool

    func hasAddedEnough(of reactant: PrecipitationComponents.Reactant) -> Bool
}

protocol PrecipitationComponentsReaction {
    func initialCoords(for molecule: PrecipitationComponents.Molecule) -> [GridCoordinate]

    func finalCoords(for molecule: PrecipitationComponents.Molecule) -> [GridCoordinate]

    var reactionsToRun: Int { get }

    func runOneReactionProgressReaction()

    func runAllReactionProgressReactions(duration: TimeInterval)
}
