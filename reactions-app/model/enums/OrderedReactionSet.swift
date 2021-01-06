//
// Reactions App
//
  

import Foundation

enum OrderedReactionSet: Int, CaseIterable {
    case A, B, C
}

extension OrderedReactionSet: Identifiable {
    var id: Int {
        self.rawValue
    }
}

extension OrderedReactionSet {
    var name: String {
        switch (self) {
        case .A: return "A to B"
        case .B: return "C to D"
        case .C: return "E to F"
        }
    }
}
