//
// Reactions App
//
  

import SwiftUI

class ZeroOrderReactionViewModel: ObservableObject {

    init () {
        setMoleculesA(cols: MoleculeGridSettings.cols, rows: MoleculeGridSettings.rows)
        input.didSetC1 = didSetC1
    }

    var navigation: NavigationViewModel<ReactionState>?

    @Published var statement = [TextLine]()
    @Published var input: ReactionInputModel = ReactionInputAllProperties(order: .Zero)

    @Published var currentTime: CGFloat?

    @Published var reactionHasEnded: Bool = false
    @Published var reactionHasStarted: Bool = false

    @Published var highlightedElements = [OrderedReactionScreenElement]()
    @Published var inputsAreDisabled = false
    @Published var canSelectReaction = false
    @Published var showReactionToggle = false

    var selectedReaction = OrderedReactionSet.A {
        didSet {
            navigation?.next()
        }
    }

    func next() {
        navigation?.next()
    }

    func back() {
        navigation?.back()
    }

    func didSetC1() {
        setMoleculesA(cols: MoleculeGridSettings.cols, rows: MoleculeGridSettings.rows)
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
