//
// Reactions App
//

@testable import ReactionRates

extension ZeroOrderReactionViewModel {
    var firstLine: String {
        statement.first!.plainString
    }
}
