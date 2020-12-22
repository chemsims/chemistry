//
// Reactions App
//
  

import Foundation

enum QuizOption: CaseIterable {
    case A, B, C, D
}

enum QuizDifficulty: String, CaseIterable {
    case skip, easy, medium, hard

    var quizLength: Int {
        switch (self) {
        case .skip: return 0
        case .easy: return 5
        case .medium: return 10
        case .hard: return 20
        }
    }
}
