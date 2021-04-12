//
// Reactions App
//

import Foundation

enum SolubleReactionType: Int, CaseIterable, SelectableReaction {

    case A, B, C

    var id: Int {
        rawValue
    }

    var reactantDisplay: String {
        "\(components.0)\(components.1)(s)"
    }

    var productDisplay: String {
        "\(components.0)+ + \(components.1)-"
    }

    private var components: (String, String) {
        switch self {
        case .A: return ("A", "B")
        case .B: return ("C", "D")
        case .C: return ("E", "F")
        }
    }
}
