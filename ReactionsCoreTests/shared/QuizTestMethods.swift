//
// Reactions App
//

import XCTest
import ReactionsCore

public func testUniqueQuestionIds(questions: [QuizQuestion]) {
    // Rather then just compare size of set to size of questions, check each element so that any duplicate is printed immediately
    let allIds = questions.map(\.id)
    allIds.forEach { id in
        XCTAssertEqual(allIds.filter { $0 == id }.count, 1, id)
    }
}

public func testUniqueQuestionOptions(questions: [QuizQuestion]) {
    questions.forEach { question in
        let allAnswers = question.options.values
        allAnswers.forEach { answer in
            let filteredAnswer = allAnswers.filter { $0.answer == answer.answer }
            let filteredExplanation = allAnswers.filter { $0.explanation == answer.explanation }

            let debug = "\(question.id) - \(answer)"

            XCTAssertEqual(filteredAnswer.count, 1, debug)
            XCTAssertEqual(filteredExplanation.count, 1, debug)
        }
    }
}
