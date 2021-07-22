//
// Reactions App
//

import Foundation

enum ReactionOrder: Int, CaseIterable, Codable {
    case Zero, First, Second
}

extension ReactionOrder: Identifiable {
    var id: Int { self.rawValue }
}

extension ReactionOrder {
    var name: String {
        switch self {
        case .Zero: return "Zero"
        case .First: return "First"
        case .Second: return "Second"
        }
    }
}
