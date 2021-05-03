//
// Reactions App
//


import Foundation

public struct QuizQuestionReader {

    private init() { }

    private static let headerRows = 2
    private static let tableRowSeparator: Character = "\n"
    private static let fileType = "csv"
    private static let colSeparator: Character = ","

    public static func read<QuestionSet>(
        from fileName: String,
        questionSet: QuestionSet,
        bundle: Bundle = Bundle.main
    ) -> ReadResult<QuizQuestionsList<QuestionSet>> {
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
                return .failure(reason: .couldNotReadContents)
            }
        }
        return .failure(reason: .missingFile)
    }

    private static func parseCsv(
        contents: String
    ) -> [CsvRow] {
        let parsed = CsvParser.parse(content: contents)
        return parsed.indices.map { i in
            CsvRow(underlying: parsed[i], index: i)
        }
    }

    private static func parseLines(
        rows: [CsvRow]
    ) -> ReadResult<[QuizQuestionData]> {
        let parsed = rows.map(parseLine)

        let valid = parsed.compactMap(\.option)
        let errors = parsed.compactMap(\.error)

        if errors.isEmpty {
            return .success(valid)
        } else {
            return .failure(reason: .multiple(reasons: errors))
        }
    }

    private static func parseLine(
        row: CsvRow
    ) -> ReadResult<QuizQuestionData> {

        let idResult = row.getRequired(\.id)
        let questionResult = row.getRequired(\.question)
        let difficultyResult = readDifficulty(row: row)
        let imageResult = readImage(row: row)
        let tableResult = readTable(row: row)
        let correctAnswerResult = readQuizAnswer(row: row, startCol: columns.correctText)
        let incorrect1Result = readQuizAnswer(row: row, startCol: columns.incorrect1Text)
        let incorrect2Result = readQuizAnswer(row: row, startCol: columns.incorrect2Text)
        let incorrect3Result = readQuizAnswer(row: row, startCol: columns.incorrect3Text)

        guard
            let id = idResult.option,
            let question = questionResult.option,
            let difficulty = difficultyResult.option,
            let image = imageResult.option,
            let table = tableResult.option,
            let correctAnswer = correctAnswerResult.option,
            let incorrect1 = incorrect1Result.option,
            let incorrect2 = incorrect2Result.option,
            let incorrect3 = incorrect3Result.option
        else {
            let results = [
                idResult.error,
                questionResult.error,
                difficultyResult.error,
                imageResult.error,
                tableResult.error,
                correctAnswerResult.error,
                incorrect1Result.error,
                incorrect2Result.error,
                incorrect3Result.error
            ]
            let failures = results.compactMap { $0 }
            return .failure(reason: .multiple(reasons: failures))
        }

        let data = QuizQuestionData(
            id: id,
            question: question,
            questionLabel: nil,
            correctAnswer: correctAnswer,
            otherAnswers: [incorrect1, incorrect2, incorrect3],
            difficulty: difficulty,
            image: image,
            table: table
        )
        return .success(data)
    }

    private static func readDifficulty(row: CsvRow) -> ReadResult<QuizDifficulty> {
        row.getRequired(\.difficulty).flatMap { result in
            if let difficulty = QuizDifficulty.from(string: result) {
                return .success(difficulty)
            }
            return .failure(reason: .invalidDifficulty(rowIndex: row.index, content: result))
        }
    }

    private static func readQuizAnswer(
        row: CsvRow,
        startCol: Column
    ) -> ReadResult<QuizAnswerData> {

        let answerResult = row.getRequired(column: startCol)
        let explanationResult = row.getRequired(column: Columns.explanationCol(question: startCol))
        let positionResult = readOption(row: row, col: Columns.positionCol(question: startCol))

        guard
            let answer = answerResult.option,
            let explanation = explanationResult.option,
            let position = positionResult.option
        else {
            let errors = [answerResult.error, explanationResult.error, positionResult.error].compactMap { $0 }
            return .failure(reason: .multiple(reasons: errors))
        }

        let data = QuizAnswerData(
            answer: answer,
            explanation: explanation,
            position: position
        )

        return .success(data)
    }

    private static func readImage(
        row: CsvRow
    ) -> ReadResult<LabelledImage?> {
        let nameResult = row.getRequired(\.image)
        let labelResult = row.getRequired(\.imageLabel)

        if let name = nameResult.option, let label = labelResult.option {
            return .success(LabelledImage(image: name, label: label))
        }

        if nameResult.option == nil && labelResult.option == nil {
            return .success(nil)
        }

        let errors = [nameResult.error, labelResult.error].compactMap { $0 }
        return .failure(reason: .multiple(reasons: errors))
    }

    private static func readTable(
        row: CsvRow
    ) -> ReadResult<QuizTable?> {
        let dataResult = row.getRequired(\.table)
        guard let data = dataResult.option else {
            return .success(nil)
        }

        let rows = data.split(separator: tableRowSeparator).map { tableRow in
            tableRow.split(separator: "|").map { cell -> TextLine in
                let str = cell.trimmingCharacters(in: .whitespacesAndNewlines)
                return TextLine(stringLiteral: str)
            }
        }
        if let quiz = QuizTable.build(from: rows) {
            return .success(quiz)
        }
        return .failure(reason: .invalidTable(rowIndex: row.index))
    }

    private static func readOption(row: CsvRow, col: Column) -> ReadResult<QuizOption?> {
        guard let result = row.getOptional(column: col) else {
            return .success(nil)
        }

        if let option = QuizOption(rawValue: result) {
            return .success(option)
        }
        return .failure(reason: .invalidPosition(rowIndex: row.index, name: col.name, content: result))
    }

    private static let columns = Columns.shared
}

private struct CsvRow {

    let underlying: [String]
    let index: Int

    private let columns = Columns.shared

    func getRequired(_ kp: KeyPath<Columns, Column>) -> ReadResult<String> {
        getRequired(column: columns[keyPath: kp])
    }

    func getRequired(column: Column) -> ReadResult<String> {
        if let result = getOptional(index: column.index), !result.isEmpty {
            return .success(result)
        }
        return .failure(reason: .missingCell(rowIndex: index, name: column.name))
    }

    func getOptional(column: Column) -> String? {
        getOptional(index: column.index)
    }

    func getOptional(index: Int) -> String? {
        if let result = underlying[safe: index]?.trimmingCharacters(in: .whitespaces),
           !result.isEmpty {
            return result
        }
        return nil
    }
}

public enum ReadResult<Data> {
    case success(_ data: Data)
    case failure(reason: QuizReadFailure)

    func map<MappedData>(_ transform: (Data) -> MappedData) -> ReadResult<MappedData> {
        flatMap { .success(transform($0)) }
    }

    func flatMap<MappedData>(_ transform: (Data) -> ReadResult<MappedData>) -> ReadResult<MappedData> {
        switch self {
        case let .success(data): return transform(data)
        case let .failure(reason: reason): return .failure(reason: reason)
        }
    }

    var option: Data? {
        switch self {
        case let .success(data): return data
        case .failure: return nil
        }
    }

    var error: QuizReadFailure? {
        if case let .failure(reason) = self {
            return reason
        }
        return nil
    }
}

public enum QuizReadFailure: Equatable {
    case missingFile,
         couldNotReadContents,
         invalidDifficulty(rowIndex: Int, content: String),
         invalidPosition(rowIndex: Int, name: String, content: String),
         missingCell(rowIndex: Int, name: String),
         invalidTable(rowIndex: Int)

    indirect case multiple(reasons: [QuizReadFailure])

    func list() -> [QuizReadFailure] {
        switch self {
        case let .multiple(reasons): return reasons.flatMap { $0.list() }
        default: return [self]
        }
    }

    var describe: String {
        switch self {
        case .missingFile: return "File missing"
        case .couldNotReadContents: return "Could not read file to string"
        case let .invalidDifficulty(rowIndex, content):
            return "Could not parse '\(content)' as a difficulty at index \(rowIndex)"
        case let .invalidPosition(rowIndex, name, content):
            return "Could not parse '\(content)' as a position at col \(name), index \(rowIndex)"
        case let .invalidTable(rowIndex):
            return "Could not parse table at index \(rowIndex)"
        case let .missingCell(rowIndex, name):
            return "Missing cell at col \(name), index \(rowIndex)"
        case let .multiple(reasons):
            return reasons.reduce("\n") { $0 + "\n\($1)" }
        }
    }
}

struct Columns {

    private init() { }
    static let shared = Columns()

    let id = Column(index: 0, name: "id")
    let question = Column(index: 1, name: "question")
    let difficulty = Column(index: 2, name: "difficulty")
    let image = Column(index: 3, name: "image")
    let imageLabel = Column(index: 4, name: "imageLabel")
    let table = Column(index: 5, name: "table")
    let correctText = Column(index: 6, name: "Correct answer")
    let incorrect1Text = Column(index: 9, name: "Incorrect answer 1")
    let incorrect2Text = Column(index: 12, name: "Incorrect answer 2")
    let incorrect3Text = Column(index: 15, name: "Incorrect answer 3")

    static func explanationCol(question: Column) -> Column {
        Column(index: question.index + 1, name: "\(question.name) explanation")
    }

    static func positionCol(question: Column) -> Column {
        Column(index: question.index + 2, name: "\(question.name) position")
    }
}

struct Column {
    let index: Int
    let name: String
}
