//
// Reactions App
//

import Foundation

public struct QuizTable: Equatable {
    public let rows: [[TextLine]]

    public init(rows: [[TextLine]]) {
        assert(rows.count != 0 && rows.allSatisfy { $0.count == rows.first!.count })
        self.rows = rows
    }

    public var cols: Int {
        rows.first!.count
    }
}
