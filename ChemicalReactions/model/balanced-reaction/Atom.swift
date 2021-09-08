//
// Reactions App
//

import SwiftUI
import ReactionsCore

extension BalancedReaction {
    enum Atom: Identifiable, CaseIterable {
        case carbon, hydrogen, nitrogen, oxygen

        var id: String {
            symbol
        }

        var symbol: String {
            switch self {
            case .carbon: return "C"
            case .hydrogen: return "H"
            case .nitrogen: return "N"
            case .oxygen: return "O"
            }
        }

        var color: Color {
            switch self {
            case .carbon: return RGB.carbon.color
            case .hydrogen: return RGB.hydrogen.color
            case .nitrogen: return RGB.nitrogen.color
            case .oxygen: return RGB.oxygen.color
            }
        }
    }

    struct AtomCount {
        init(atom: BalancedReaction.Atom, count: Int) {
            assert(count >= 1)
            self.count = count
            self.atom = atom
        }

        let atom: BalancedReaction.Atom
        let count: Int
    }
}
