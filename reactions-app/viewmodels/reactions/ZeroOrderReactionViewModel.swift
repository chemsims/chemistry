//
// Reactions App
//
  

import SwiftUI

class ZeroOrderReactionViewModel: ObservableObject {

    init () {
        setMoleculesA(cols: MoleculeGridSettings.cols, rows: MoleculeGridSettings.rows)
    }

    @Published var initialConcentration: CGFloat = 0.5 {
        didSet {
            setMoleculesA(cols: MoleculeGridSettings.cols, rows: MoleculeGridSettings.rows)
        }
    }
    @Published var initialTime: CGFloat = 6.6
    @Published var finalConcentration: CGFloat?
    @Published var finalTime: CGFloat?

    @Published var currentTime: CGFloat?

    @Published var reactionHasEnded: Bool = false

    var concentrationEquationA: ConcentrationEquation {
        if let t2 = finalTime, let c2 = finalConcentration {
            return LinearConcentration(
                t1: initialTime,
                c1: initialConcentration,
                t2: t2,
                c2: c2
            )
        }
        return ConstantConcentration(value: initialConcentration)
    }

    var concentrationEquationB: ConcentrationEquation {
        return ConcentrationBEquation(
            concentrationA: concentrationEquationA,
            initialAConcentration: initialConcentration
        )
    }

    var moleculesA = [GridCoordinate]()

    var deltaC: CGFloat? {
        if let c2 = finalConcentration {
            return c2.rounded(decimals: 2) - initialConcentration.rounded(decimals: 2)
        }
        return nil
    }

    var deltaT: CGFloat? {
        if let t2 = finalTime {
            return t2.rounded(decimals: 2) - initialTime.rounded(decimals: 2)
        }
        return nil
    }

    var rate: CGFloat? {
        if let deltaC = deltaC, deltaC != 0, let deltaT = deltaT {
            return -deltaC / deltaT
        }
        return nil
    }

    var a0: CGFloat? {
        if rate != nil {
            return concentrationEquationA.getConcentration(at: 0)
        }
        return nil
    }

    var halfTime: CGFloat? {
        if let a0 = a0, let rate = rate, rate != 0 {
            return a0 / (2 * rate)
        }
        return nil
    }

    var reactionDuration: CGFloat? {
        if let t2 = finalTime {
            return t2 - initialTime
        }
        return nil
    }

    private func setMoleculesA(
        cols: Int,
        rows: Int
    ) {
        let desiredMolecues = Int(initialConcentration * CGFloat(cols * rows))

        let surplus = desiredMolecues - moleculesA.count
        if (surplus < 0) {
            let toRemove = min(moleculesA.count, -1 * surplus)
            moleculesA.removeFirst(toRemove)
        } else {
            addMoleculesA(surplus, cols: cols, rows: rows)
        }
        return
    }

    private func addMoleculesA(
        _ toAdd: Int,
        cols: Int,
        rows: Int
    ) {
        if (toAdd == 0 || moleculesA.count == (cols * rows)) {
            return
        }
        let grid = GridCoordinate.random(maxCol: cols - 1, maxRow: rows - 1)
        let moleculeExists = moleculesA.contains { $0.col == grid.col && $0.row == grid.row }
        if (moleculeExists) {
            addMoleculesA(toAdd, cols: cols, rows: rows)
        } else {
            moleculesA.append(grid)
            addMoleculesA(toAdd - 1, cols: cols, rows: rows)
        }
    }
}
