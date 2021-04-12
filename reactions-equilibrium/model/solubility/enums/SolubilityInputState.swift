//
// Reactions App
//


import Foundation

enum SolubilityInputState: Equatable {
    case none, addSaturatedSolute, setWaterLevel, selectingReaction
    case addSolute(type: SoluteType)

    func addingSolute(type: SoluteType) -> Bool {
        self == .addSolute(type: type) || (type == .primary && self == .addSaturatedSolute)
    }
}
