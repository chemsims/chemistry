//
// Reactions App
//
  

import Foundation

enum ReactionType: Int, CaseIterable {
    case A, B, C
}

extension ReactionType: Identifiable {
    var id: Int {
        self.rawValue
    }
}

extension ReactionType {
    var name: String {
        switch (self) {
        case .A: return "A to B"
        case .B: return "C to D"
        case .C: return "E to F"
        }
    }
}
