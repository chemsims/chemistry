//
// Reactions App
//

import ReactionsCore

struct AcidAppNavigationRows {
    private init() { }
    
    static let rows = NavigationRows(TopLevelScreen.allCases.map(\.row))
}

private enum TopLevelScreen: CaseIterable {
    case introduction, buffer, titration

    var row: NavigationRow<AcidAppScreen> {
        NavigationRow(
            primaryIcon: NavigationIcon(
                screen: screen,
                image: .framework(image, bundle: .acidBases),
                selectedImage: .framework("\(image)-pressed", bundle: .acidBases),
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

    private var screen: AcidAppScreen {
        switch self {
        case .introduction: return .introduction
        case .buffer: return .buffer
        case .titration: return .titration
        }
    }

    private var quizScreen: AcidAppScreen {
        switch self {
        case .introduction: return .introductionQuiz
        case .buffer: return .bufferQuiz
        case .titration: return .titrationQuiz
        }
    }

    private var image: String {
        switch self {
        case .introduction: return "introduction"
        case .buffer: return "buffer"
        case .titration: return "titration"
        }
    }

    private var label: String {
        switch self {
        case .introduction: return "Acid & Bases introduction"
        case .buffer: return "Buffers"
        case .titration: return "Titration"
        }
    }
}
