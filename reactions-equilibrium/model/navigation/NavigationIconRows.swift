//
// Reactions App
//

import ReactionsCore

struct ReactionEquilibriumNavigationRows {
    static let rows = NavigationRow.allCases.map(\.row)
}

private enum NavigationRow: CaseIterable {
    case aqueous, gaseous, solubility

    var row: NavigationIconRow<EquilibriumAppScreen> {
        NavigationIconRow(
            primaryIcon: NavigationIcon(
                screen: screen,
                image: .application(icon),
                selectedImage: .application("\(icon)-pressed"),
                label: label
            ),
            firstSecondaryIcon: NavigationIcon(
                screen: quizScreen,
                image: .core(.quizIcon),
                selectedImage: .core(.quizIconSelected),
                label: "\(label) quiz"
            ),
            secondSecondaryIcon: nil
        )
    }

    var screen: EquilibriumAppScreen {
        switch self {
        case .aqueous: return .aqueousReaction
        case .gaseous: return .gaseousReaction
        case .solubility: return .solubility
        }
    }

    private var label: String {
        switch self {
        case .aqueous: return "Aqueous reaction"
        case .gaseous: return "Gaseous reaction"
        case .solubility: return "Solubility reaction"
        }
    }

    private var icon: String {
        switch self {
        case .aqueous: return "aqueousicon"
        case .gaseous: return "gaseousicon"
        case .solubility: return "solubilityicon"
        }
    }

    private var quizScreen: EquilibriumAppScreen {
        switch self {
        case .aqueous: return .aqueousQuiz
        case .gaseous: return .gaseousQuiz
        case .solubility: return .solubilityQuiz
        }
    }
}
