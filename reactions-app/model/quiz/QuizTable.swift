//
// Reactions App
//
  

import Foundation

struct QuizTable: Equatable {
    let rows: [[TextLine]]

    init(rows: [[String]]) {
        assert(rows.count != 0 && rows.allSatisfy{ $0.count == rows.first!.count })
        self.rows = rows.map { row in
            row.map { cell in
                TextLine(cell, label: Labelling.stringToLabel(cell))
            }
        }
    }

    var cols: Int {
        rows.first!.count
    }
}

