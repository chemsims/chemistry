//
// Reactions App
//

import Foundation

public struct QuizTable: Equatable {
    public let rows: [[TextLine]]

    public init(rows: [[TextLine]]) {
        assert(Self.rowsAreValid(rows: rows))
        self.rows = rows
    }

    public static func build(from rows: [[TextLine]]) -> QuizTable? {
        rowsAreValid(rows: rows) ? QuizTable(rows: rows) : nil
    }

    private static func rowsAreValid(
        rows: [[TextLine]]
    ) -> Bool {
        rows.count != 0 && rows.allSatisfy { $0.count == rows.first!.count }
    }

    public var cols: Int {
        rows.first!.count
    }
}
