//
// Reactions App
//

import ReactionsCore

struct ReactionRateNavigationRows {
    static let rows: [NavigationIconRow<AppScreen>] = TopLevelScreen.allCases.map(\.row)
}

private enum TopLevelScreen: CaseIterable {
    case zeroOrderReaction,
          firstOrderReaction,
          secondOrderReaction,
          reactionComparison,
          energyProfile

    var row: NavigationIconRow<AppScreen> {
        NavigationIconRow(
            primaryIcon: NavigationIcon(
                screen: appScreen,
                image: navImage,
                pressedImage: navImagePressed,
                isSystemImage: false,
                label: label
            ),
            firstSecondaryIcon: NavigationIcon(
                screen: quizScreen,
                image: "text-book-closed",
                pressedImage: "text-book-closed",
                isSystemImage: false,
                label: "\(label) quiz"
            ),
            secondSecondaryIcon: filingScreen.map {
                NavigationIcon(
                    screen: $0,
                    image: "archivebox-thinner",
                    pressedImage: "archivebox-thinner",
                    isSystemImage: false,
                    label: "\(label) saved snapshots"
                )
            }
        )
    }

    var navImage: String {
        switch self {
        case .zeroOrderReaction: return "zeroordericon"
        case .firstOrderReaction: return "firstordericon"
        case .secondOrderReaction: return "secondordericon"
        case .reactionComparison: return "comparisonicon"
        case .energyProfile: return "kineticsicon"
        }
    }

    var navImagePressed: String {
        "\(navImage)-pressed"
    }

    var appScreen: AppScreen {
        switch self {
        case .zeroOrderReaction: return .zeroOrderReaction
        case .firstOrderReaction: return .firstOrderReaction
        case .secondOrderReaction: return .secondOrderReaction
        case .reactionComparison: return .reactionComparison
        case .energyProfile: return .energyProfile
        }
    }

    var quizScreen: AppScreen {
        switch self {
        case .zeroOrderReaction: return .zeroOrderReactionQuiz
        case .firstOrderReaction: return .firstOrderReactionQuiz
        case .secondOrderReaction: return .secondOrderReactionQuiz
        case .reactionComparison: return .reactionComparisonQuiz
        case .energyProfile: return .energyProfileQuiz
        }
    }

    var filingScreen: AppScreen? {
        switch self {
        case .zeroOrderReaction: return .zeroOrderFiling
        case .firstOrderReaction: return .firstOrderFiling
        case .secondOrderReaction: return .secondOrderFiling
        case .energyProfile: return .energyProfileFiling
        default: return nil
        }
    }

    var label: String {
        switch self {
        case .zeroOrderReaction: return "Zero order reaction"
        case .firstOrderReaction: return "First order reaction"
        case .secondOrderReaction: return "Second order reaction"
        case .reactionComparison: return "Reaction comparison"
        case .energyProfile: return "Energy profile"
        }
    }
}
