//
// Reactions App
//


import SwiftUI

class ReactionViewModel: ObservableObject {

    init () {
        setMolecules(cols: 19, rows: 10)
    }

    @Published var initialConcentration: Double = 0.4 {
        didSet {
            setMolecules(cols: 19, rows: 10)
        }
    }
    @Published var initialTime: Double = 10
    @Published var finalConcentration: Double?
    @Published var finalTime: Double?

    var molecules: [GridCoordinate] = []

    var deltaC: Double? {
        if let c2 = finalConcentration {
            return c2 - initialConcentration
        }
        return nil
    }

    var deltaT: Double? {
        if let t2 = finalTime {
            return t2 - initialTime
        }
        return nil
    }

    var rate: Double? {
        if let deltaC = deltaC, let deltaT = deltaT {
            return deltaT / deltaC
        }
        return nil
    }

    private func setMolecules(
        cols: Int,
        rows: Int
    ) {
        let desiredMolecues = Int(initialConcentration * Double(cols * rows))

        let surplus = desiredMolecues - molecules.count
        if (surplus < 0) {
            molecules.removeFirst(-1 * surplus)
        } else {
            addMolecules(surplus, cols: cols, rows: rows)
        }
        return
    }

    private func addMolecules(
        _ toAdd: Int,
        cols: Int,
        rows: Int
    ) {
        if (toAdd == 0 || molecules.count == (cols * rows)) {
            return
        }
        let grid = GridCoordinate.random(maxCol: cols - 1, maxRow: rows - 1)
        let moleculeExists = molecules.contains { $0.col == grid.col && $0.row == grid.row }
        if (moleculeExists) {
            addMolecules(toAdd, cols: cols, rows: rows)
        } else {
            molecules.append(grid)
            addMolecules(toAdd - 1, cols: cols, rows: rows)
        }
    }

}

struct ReactionSettings {
    static let minConcentration: Double = 0.2
    static let maxConcentration: Double = 1

    static let minTime: Double = 1
    static let maxTime: Double = 30
}
