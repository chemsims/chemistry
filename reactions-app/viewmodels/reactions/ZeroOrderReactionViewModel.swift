//
// Reactions App
//
  

import SwiftUI

class ZeroOrderReactionViewModel: ObservableObject {

    init () {
        setMoleculesA(cols: MoleculeGridSettings.cols, rows: MoleculeGridSettings.rows)
    }

    @Published var initialConcentration: CGFloat = ReactionSettings.initialC {
        didSet {
            setMoleculesA(cols: MoleculeGridSettings.cols, rows: MoleculeGridSettings.rows)
        }
    }
    @Published var initialTime: CGFloat = ReactionSettings.initialT
    @Published var finalConcentration: CGFloat?
    @Published var finalTime: CGFloat?

    @Published var currentTime: CGFloat?

    @Published var reactionHasEnded: Bool = false
    @Published var reactionHasStarted: Bool = false

    @Published var highlightedElements = [OrderedReactionScreenHighlightingElements]()

    func generateEquation(
        c1: CGFloat,
        c2: CGFloat,
        t1: CGFloat,
        t2: CGFloat
    ) -> ConcentrationEquation {
        ZeroOrderReaction(
            t1: initialTime,
            c1: initialConcentration,
            t2: t2,
            c2: c2
        )
    }

    func color(for element: OrderedReactionScreenHighlightingElements?) -> Color {
        if (highlightedElements.isEmpty) {
            return .white
        }
        if let element = element, highlightedElements.contains(element) {
            return .white
        }
        return Styling.inactiveScreenElement
    }

    var concentrationEquationA: ConcentrationEquation? {
        if let t2 = finalTime, let c2 = finalConcentration {
            return generateEquation(
                c1: initialConcentration.rounded(decimals: 2),
                c2: c2.rounded(decimals: 2),
                t1: initialTime.rounded(decimals: 2),
                t2: t2.rounded(decimals: 2)
            )
        }
        return nil
    }

    var concentrationEquationB: Equation? {
        concentrationEquationA.map {
            ConcentrationBEquation(
                concentrationA: $0,
                initialAConcentration: initialConcentration
            )
        }
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

    var reactionDuration: CGFloat? {
        if let t2 = finalTime {
            return t2 - initialTime
        }
        return nil
    }

    var input: ReactionInput? {
        if let c2 = finalConcentration, let t2 = finalTime {
            return ReactionInput(
                c1: initialConcentration,
                c2: c2,
                t1: initialTime,
                t2: t2
            )
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
