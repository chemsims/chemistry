//
// Reactions App
//


import Foundation

enum SolubilityInputState: Equatable {
    case none, addSaturatedSolute, setWaterLevel
    case addSolute(type: SoluteType)

    var isAddingSolute: Bool {
        if case .addSolute = self {
            return true
        }
        return self == .addSaturatedSolute
    }

    func addingSolute(type: SoluteType) -> Bool {
        self == .addSolute(type: type) || (type == .primary && self == .addSaturatedSolute)
    }
}
