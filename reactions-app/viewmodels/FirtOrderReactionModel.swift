//
// Reactions App
//


import SwiftUI

class FirstOderViewModel: ReactionViewModel {

    override var concentrationEquationA: ConcentrationEquation {
        if let rate = rate {
            return FirstOrderConcentration(
                initialConcentration: initialConcentration,
                rate: rate
            )
        }
        return ConstantConcentration(value: 0.5)
    }

    var logAEquation: ConcentrationEquation {
        LogEquation(underlying: concentrationEquationA)
    }

    override var rate: CGFloat? {
        if let finalConcentration = finalConcentration, let finalTime = finalTime, initialConcentration != 0, finalTime != 0 {
            let logC = log(finalConcentration / initialConcentration)
            return -1 * (logC / finalTime)
        }
        return nil
    }

    override var halfTime: CGFloat? {
        if let rate = rate {
            return log(2) / rate
        }
        return nil
    }
}

class ReactionViewModel: ObservableObject {

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
    @Published var moleculeBOpacity: Double = 0

    @Published var reactionHasEnded: Bool = false
    @Published var timeChartHeadOpacity: Double = 1

    var concentrationEquationA: ConcentrationEquation {
        if let t2 = finalTime, let c2 = finalConcentration {
            return LinearConcentration(
                t1: initialTime,
                c1: initialConcentration,
                t2: t2,
                c2: c2
            )
        }
        return ConstantConcentration(value: 0)
    }

    var concentrationEquationB: ConcentrationEquation {
        return ConcentrationBEquation(
            concentrationA: concentrationEquationA,
            initialAConcentration: initialConcentration
        )
    }

    var moleculesA = [GridCoordinate]()
    var moleculesB: [GridCoordinate] {
        if let finalTime = finalTime, finalConcentration != nil {
            let finalB = concentrationEquationB.getConcentration(at: finalTime)
            let desiredMolecues = finalB * CGFloat(MoleculeGridSettings.cols * MoleculeGridSettings.rows)
            let prefix = moleculesA.prefix(Int(desiredMolecues))
            return Array(prefix)
        }
        return []
    }

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

struct ReactionSettings {

    // Axis settings
    static let minConcentration: CGFloat = 0
    static let maxConcentration: CGFloat = 1
    static let minTime: CGFloat = 0
    static let maxTime: CGFloat = 17

    static let minLogConcentration: CGFloat = -4
    static let maxLogConcentration: CGFloat = 0

    /// The minimum value that concentration 2 may be. Concentration 1 is liited to ensure there is sufficient space
    static let minFinalConcentration: CGFloat = 0.15

    /// The minimum value that time 2 may be. Time 1 is liited to ensure there is sufficient space
    static let minFinalTime: CGFloat = 13
}
