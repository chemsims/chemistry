//
// Reactions App
//

import ReactionsCore

struct ReactionEquilibriumNavigationRows {
    static let rows = NavigationRows(
        TopLevelScreen.allCases.map(\.row),
        secondary: [integration]
    )

    static let integration = NavigationRow(
        primaryIcon: NavigationIcon<EquilibriumScreen>(
            screen: .integrationActivity,
            image: .framework("integrationicon", bundle: .equilibrium),
            selectedImage: .framework("integrationicon-pressed", bundle: .equilibrium),
            label: "Equilibrium & rates integration"
        ),
        firstSecondaryIcon: nil,
        secondSecondaryIcon: nil
    )
}

private enum TopLevelScreen: CaseIterable {
    case aqueous, gaseous, solubility

    var row: NavigationRow<EquilibriumScreen> {
        NavigationRow(
            primaryIcon: NavigationIcon(
                screen: screen,
                image: .framework(icon, bundle: .equilibrium),
                selectedImage: .framework("\(icon)-pressed", bundle: .equilibrium),
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

    var screen: EquilibriumScreen {
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

    private var quizScreen: EquilibriumScreen {
        switch self {
        case .aqueous: return .aqueousQuiz
        case .gaseous: return .gaseousQuiz
        case .solubility: return .solubilityQuiz
        }
    }
}
