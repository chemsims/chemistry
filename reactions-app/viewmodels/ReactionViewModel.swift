//
// Reactions App
//


import SwiftUI

class ReactionViewModel: ObservableObject {

    init () {
        setMolecules(cols: 19, rows: 10)
    }

    @Published var initialConcentration: CGFloat = 0.5 {
        didSet {
            setMolecules(cols: 19, rows: 10)
        }
    }
    @Published var initialTime: CGFloat = 6.6
    @Published var finalConcentration: CGFloat?
    @Published var finalTime: CGFloat?

    @Published var currentTime: CGFloat?

    var concentrationEquationA: LinearConcentration {
        LinearConcentration(
            t1: initialTime,
            c1: initialConcentration,
            t2: finalTime ?? 0,
            c2: finalConcentration ?? 0
        )
    }

    var concentrationEquationB: LinearConcentration {
        concentrationEquationA.inverse
    }

    var molecules: [GridCoordinate] = []

    var deltaC: CGFloat? {
        if let c2 = finalConcentration {
            return c2 - initialConcentration
        }
        return nil
    }

    var deltaT: CGFloat? {
        if let t2 = finalTime {
            return t2 - initialTime
        }
        return nil
    }

    var rate: CGFloat? {
        if let deltaC = deltaC, deltaC != 0, let deltaT = deltaT {
            return -deltaC / deltaT
        }
        return nil
    }

    var halfTime: CGFloat? {
        if let rate = rate, rate != 0 {
            return initialConcentration / (2 * rate)
        }
        return nil
    }

    private func setMolecules(
        cols: Int,
        rows: Int
    ) {
        let desiredMolecues = Int(initialConcentration * CGFloat(cols * rows))

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
    static let minConcentration: CGFloat = 0.2
    static let maxConcentration: CGFloat = 1

    static let minTime: CGFloat = 1
    static let maxTime: CGFloat = 30
}
