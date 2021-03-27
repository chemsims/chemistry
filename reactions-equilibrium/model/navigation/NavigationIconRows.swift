//
// Reactions App
//

import ReactionsCore

struct ReactionEquilibriumNavigationRows {
    static let rows = NavigationRow.allCases.map(\.row)
}

private enum NavigationRow: CaseIterable {
    case aqueous, gaseous

    var row: NavigationIconRow<EquilibriumAppScreen> {
        NavigationIconRow(
            primaryIcon: NavigationIcon(
                screen: screen,
                image: icon,
                pressedImage: icon,
                isSystemImage: false,
                label: label
            ),
            firstSecondaryIcon: nil,
            secondSecondaryIcon: nil
        )
    }

    var screen: EquilibriumAppScreen {
        switch self {
        case .aqueous: return .aqueousReaction
        case .gaseous: return .gaseousReaction
        }
    }

    var label: String {
        switch self {
        case .aqueous: return "Aqueous reaction"
        case .gaseous: return "Gaseous reaction"
        }
    }

    private var icon: String {
        switch self {
        case .aqueous: return "aqueousicon"
        case .gaseous: return "gaseousicon"
        }
    }
}
