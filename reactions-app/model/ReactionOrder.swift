//
// Reactions App
//
  

import Foundation

enum ReactionOrder: Int, CaseIterable {
    case Zero, First, Second
}

extension ReactionOrder: Identifiable {
    var id: Int { self.rawValue }
}
