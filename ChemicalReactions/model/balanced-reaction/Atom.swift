//
// Reactions App
//

import SwiftUI
import ReactionsCore

extension BalancedReaction {
    enum Atom: String, Identifiable, CaseIterable {
        case carbon, hydrogen, nitrogen, oxygen

        var id: String {
            rawValue
        }

        var symbol: String {
            switch self {
            case .carbon: return "C"
            case .hydrogen: return "H"
            case .nitrogen: return "N"
            case .oxygen: return "O"
            }
        }

        var name: String {
            rawValue
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

extension BalancedReaction.AtomCount {
    var displayCount: String {
        effectiveDisplayCount(moleculeCoefficient: 1)
    }

    func displayCount(formatter: (BalancedReaction.Atom) -> String) -> String {
        effectiveDisplayCount(moleculeCoefficient: 1, formatter: formatter)
    }

    func effectiveDisplayCount(moleculeCoefficient coeff: Int) -> String {
        effectiveDisplayCount(moleculeCoefficient: coeff) { $0.name }
    }


    private func effectiveDisplayCount(
        moleculeCoefficient coeff: Int,
        formatter: (BalancedReaction.Atom) -> String
    ) -> String {
        let resultingCount = coeff * count
        let atomString = resultingCount == 1 ? "atom" : "atoms"
        let formattedAtom = formatter(atom)
        return "\(resultingCount) \(atomString) of \(formattedAtom)"
    }
}
