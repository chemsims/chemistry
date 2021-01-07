//
// Reactions App
//
  

import SwiftUI

struct ReactionInputModel {

    var inputC1: CGFloat = ReactionSettings.initialC {
        didSet {
            didSetC1?()
        }
    }
    var inputT1: CGFloat = ReactionSettings.initialT
    var inputC2: CGFloat?
    var inputT2: CGFloat?

    var didSetC1: (() -> Void)?

    var concentrationA: ConcentrationEquation? {
        if let c2 = inputC2, let t2 = inputT2 {
            return ZeroOrderReaction(
                t1: inputT1,
                c1: inputC1,
                t2: t2,
                c2: c2
            )
        }
        return nil
    }

    var concentrationB: Equation? {
        concentrationA.map {
            ConcentrationBEquation(
                concentrationA: $0,
                initialAConcentration: inputC1
            )
        }
    }
}

class ZeroOrderReactionViewModel: ObservableObject {

    init () {
        input = ReactionInputModel()
        input.didSetC1 = {
            self.setMoleculesA(cols: MoleculeGridSettings.cols, rows: MoleculeGridSettings.rows)
        }
        input.didSetC1?()
    }

    @Published var statement = [TextLine]()
    @Published var input: ReactionInputModel

    @Published var currentTime: CGFloat?

    @Published var reactionHasEnded: Bool = false
    @Published var reactionHasStarted: Bool = false

    @Published var highlightedElements = [OrderedReactionScreenElement]()
    @Published var inputsAreDisabled = false

    var selectedReaction = OrderedReactionSet.A

    func generateEquation(
        c1: CGFloat,
        c2: CGFloat,
        t1: CGFloat,
        t2: CGFloat
    ) -> ConcentrationEquation {
        ZeroOrderReaction(
            t1: input.inputT1,
            c1: input.inputC1,
            t2: t2,
            c2: c2
        )
    }

    func color(for element: OrderedReactionScreenElement?) -> Color {
        if (highlightedElements.isEmpty || highlight(element: element)) {
            return .white
        }
        return Styling.inactiveScreenElement
    }

    func color(for elements: [OrderedReactionScreenElement]) -> Color {
        let index = elements.firstIndex { highlight(element: $0) }
        if (highlightedElements.isEmpty || index != nil) {
            return .white
        }
        return Styling.inactiveScreenElement
    }

    func highlight(element: OrderedReactionScreenElement?) -> Bool {
        if let element = element, highlightedElements.contains(element) {
            return true
        }
        return false
    }

    var moleculesA = [GridCoordinate]()

    var deltaC: CGFloat? {
        if let c2 = input.inputC2 {
            return c2.rounded(decimals: 2) - input.inputC1.rounded(decimals: 2)
        }
        return nil
    }

    var deltaT: CGFloat? {
        if let t2 = input.inputT2 {
            return t2.rounded(decimals: 2) - input.inputT1.rounded(decimals: 2)
        }
        return nil
    }

    var reactionDuration: CGFloat? {
        if let t2 = input.inputT2 {
            return t2 - input.inputT1
        }
        return nil
    }

    var inputToSave: ReactionInput? {
        if let c2 = input.inputC2, let t2 = input.inputT2 {
            return ReactionInput(
                c1: input.inputC1,
                c2: c2,
                t1: input.inputT1,
                t2: t2
            )
        }
        return nil
    }

    private func setMoleculesA(
        cols: Int,
        rows: Int
    ) {
        let desiredMolecues = Int(input.inputC1 * CGFloat(cols * rows))

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
