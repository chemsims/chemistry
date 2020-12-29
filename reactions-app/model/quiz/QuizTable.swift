//
// Reactions App
//
  

import Foundation

struct QuizTable {
    let rows: [[TextLine]]

    init(rows: [[TextLine]]) {
        assert(rows.count != 0 && rows.allSatisfy{ $0.count == rows.first!.count })
        self.rows = rows
    }

    var cols: Int {
        rows.first!.count
    }
}

