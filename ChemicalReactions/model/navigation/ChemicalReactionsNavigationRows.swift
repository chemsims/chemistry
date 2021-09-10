//
// Reactions App
//

import ReactionsCore

struct ChemicalReactionNavigationRows {
    private init() { }

    static let rows = NavigationRows(TopLevelScreen.allCases.map(\.row))
}

private enum TopLevelScreen: CaseIterable {
    case balancedReactions

    var row: NavigationRow<ChemicalReactionsScreen> {
        NavigationRow(
            primaryIcon: NavigationIcon(
                screen: screen,
                image: .core(.quizIcon),
                selectedImage: .core(.quizIconSelected),
                label: label
            ),
            firstSecondaryIcon: NavigationIcon(
                screen: .balancedReactionsQuiz,
                image: .core(.quizIcon),
                selectedImage: .core(.quizIconSelected),
                label: "\(label) quiz"
            ),
            secondSecondaryIcon: nil
        )
    }

    var screen: ChemicalReactionsScreen {
        switch self {
        case .balancedReactions: return .balancedReactions
        }
    }

    var quiz: ChemicalReactionsScreen {
        switch self {
        case .balancedReactions: return .balancedReactionsQuiz
        }
    }

    var label: String {
        switch self {
        case .balancedReactions: return "Balanced reactions"
        }
    }
}


