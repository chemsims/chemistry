//
// Reactions App
//

import ReactionsCore

struct ChemicalReactionNavigationRows {
    private init() { }

    static let rows = NavigationRows(TopLevelScreen.allCases.map(\.row))
}

private enum TopLevelScreen: CaseIterable {
    case balancedReactions, limitingReagent, precipitation

    var row: NavigationRow<ChemicalReactionsScreen> {
        NavigationRow(
            primaryIcon: NavigationIcon(
                screen: screen,
                image: .framework(baseIcon, bundle: .chemicalReactions),
                selectedImage: .framework("\(baseIcon)-pressed", bundle: .chemicalReactions),
                label: label
            ),
            firstSecondaryIcon: NavigationIcon(
                screen: quiz,
                image: .core(.quizIcon),
                selectedImage: .core(.quizIconSelected),
                label: "\(label) quiz"
            ),
            secondSecondaryIcon: nil
        )
    }

    var baseIcon: String {
        switch self {
        case .balancedReactions: return "balanced-reaction"
        case .limitingReagent: return "limiting-reagent"
        case .precipitation: return "precipitate"
        }
    }

    var screen: ChemicalReactionsScreen {
        switch self {
        case .balancedReactions: return .balancedReactions
        case .limitingReagent: return .limitingReagent
        case .precipitation: return .precipitation
        }
    }

    var label: String {
        switch self {
        case .balancedReactions: return "Balanced reactions"
        case .limitingReagent: return "Limiting reagent"
        case .precipitation: return "Precipitation"
        }
    }

    var quiz: ChemicalReactionsScreen {
        switch self {
        case .balancedReactions: return .balancedReactionsQuiz
        case .limitingReagent: return .limitingReagentQuiz
        case .precipitation: return .precipitationQuiz
        }
    }
}

