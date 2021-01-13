//
// Reactions App
//
  

@testable import reactions_app

extension ZeroOrderReactionViewModel {
    var firstLine: String {
        statement.first!.plainString
    }
}
