//
// Reactions App
//


import Foundation

public struct QuizQuestionReader {

    private init() { }

    private static let headerRows = 2
    private static let rowSeparator: Character = "\r\n"
    private static let fileType = "tsv"
    private static let colSeperator: Character = "\t"

    public static func read(
        from fileName: String,
        questionSet: QuestionSet,
        bundle: Bundle = Bundle.main
    ) -> QuizQuestionsList? {
        if let path = bundle.path(forResource: fileName, ofType: fileType) {
            do {
                let contents = try String(contentsOfFile: path)
                let rows = Array(parseCsv(contents: contents).dropFirst(headerRows))
                return parseLines(rows: rows).map { questions in
                    QuizQuestionsList(
                       questionSet: questionSet,
                       questions
                   )
                }
            } catch {
                return nil
            }
        }
        return nil
    }

    private static func parseCsv(
        contents: String
    ) -> [CsvRow] {
        contents.split(separator: rowSeparator).map { line in
            CsvRow(underlying: line.split(separator: colSeperator, omittingEmptySubsequences: false).map(String.init))
        }
    }

    private static func parseLines(
        rows: [CsvRow]
    ) -> [QuizQuestionData]? {
        var result = [QuizQuestionData]()
        for row in rows {
            if let parsed = parseLine(row: row) {
                result.append(parsed)
            } else {
                print("Could not read row \(row.underlying)")
                return nil
            }
        }
        return result
    }

    private static func parseLine(
        row: CsvRow
    ) -> QuizQuestionData? {
        guard
            let id = row.getRequired(\.id),
            let question = row.getRequired(\.question),
            let difficulty = row.getRequired(\.difficulty).flatMap(QuizDifficulty.from),
            let image = readImage(row: row).option,
            let table = readTable(row: row).option,
            let correctAnswer = readQuizOption(row: row, startIndex: index.correctText),
            let incorrect1 = readQuizOption(row: row, startIndex: index.incorrect1Text),
            let incorrect2 = readQuizOption(row: row, startIndex: index.incorrect2Text),
            let incorrect3 = readQuizOption(row: row, startIndex: index.incorrect3Text)
        else {
            return nil
        }

        return QuizQuestionData(
            id: id,
            question: question,
            questionLabel: nil,
            correctAnswer: correctAnswer,
            otherAnswers: [incorrect1, incorrect2, incorrect3],
            difficulty: difficulty,
            image: image,
            table: table
        )
    }

    private static func readQuizOption(
        row: CsvRow,
        startIndex: Int
    ) -> QuizAnswerData? {
        guard
            let answer = row.getRequired(index: startIndex),
            let explanation = row.getRequired(index: startIndex + 1),
            let position = row.getRaw(index: startIndex + 2).map(readOption)?.option
        else {
            return nil
        }

        return QuizAnswerData(
            answer: answer,
            explanation: explanation,
            position: position
        )
    }

    private static func readImage(
        row: CsvRow
    ) -> ReadResult<LabelledImage?> {
        let name = row.getRequired(\.image)
        let label = row.getRequired(\.imageLabel)

        if let n = name, let l = label {
            return .success(LabelledImage(image: n, label: l))
        }

        if name == nil && label == nil {
            return .success(nil)
        }

        return .failure
    }

    private static func readTable(
        row: CsvRow
    ) -> ReadResult<QuizTable?> {
        guard let data = row.getRequired(\.table) else {
            return .success(nil)
        }

        let rows = data.split(separator: "\\").map { tableRow in
            tableRow.split(separator: "|").map { cell -> TextLine in
                let str = cell.trimmingCharacters(in: .whitespaces)
                return TextLine(stringLiteral: str)
            }
        }
        if let quiz = QuizTable.build(from: rows) {
            return .success(quiz)
        }
        return .failure
    }

    private static func readOption(_ string: String) -> ReadResult<QuizOption?> {
        readIfNonEmpty(string, read: QuizOption.init)
    }

    // Returns a successful read if the contents is empty, or it can be parsed.
    // A failure is reported when the contents is non-empty and it fails to be parsed
    private static func readIfNonEmpty<Data>(
        _ contents: String,
        read: (String) -> Data?
    ) -> ReadResult<Data?> {
        let trimmed = contents.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            return .success(nil)
        }
        if let result = read(trimmed) {
            return .success(result)
        }
        return .failure
    }

    private static let index = Index.shared
}

private struct CsvRow {

    let underlying: [String]

    private let index = Index.shared

    func getRequired(_ kp: KeyPath<Index, Int>) -> String? {
        getRequired(index: index[keyPath: kp])
    }

    func getRequired(index: Int) -> String? {
        if let result = getRaw(index: index), !result.isEmpty {
            return result
        }
        return nil
    }

    func getRaw(_ kp: KeyPath<Index, Int>) -> String? {
        getRaw(index: index[keyPath: kp])
    }

    func getRaw(index: Int) -> String? {
        underlying[safe: index]?.trimmingCharacters(in: .whitespaces)
    }

}

private enum ReadResult<Data> {
    case success(_ data: Data)
    case failure

    var option: Data? {
        switch self {
        case let .success(data): return data
        case .failure: return nil
        }
    }
}

fileprivate struct Index {

    static let shared = Index()
    private init() { }

    let id = 0
    let question = 1
    let difficulty = 2
    let image = 3
    let imageLabel = 4
    let table = 5
    let correctText = 6
    let correctExplanation = 7
    let correctPos = 8
    let incorrect1Text = 9
    let incorrect1Explanation = 10
    let incorrect1Pos = 11
    let incorrect2Text = 12
    let incorrect2Explanation = 13
    let incorrect2Pos = 14
    let incorrect3Text = 15
    let incorrect3Explanation = 16
    let incorrect3Pos = 17
    let incorrect4Text = 18
    let incorrect4Explanation = 19
    let incorrect4Pos = 20
}
