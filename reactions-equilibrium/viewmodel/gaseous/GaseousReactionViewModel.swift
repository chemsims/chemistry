//
// Reactions App
//

import SwiftUI
import ReactionsCore

class GaseousReactionViewModel: ObservableObject {

    init() {
        let initialReaction = AqueousReactionType.A
        let initialRows = GaseousReactionSettings.initialRows
        self.rows = CGFloat(initialRows)
        self.componentWrapper = ReactionComponentsWrapper(
            coefficients: initialReaction.coefficients,
            equilibriumConstant: initialReaction.equilibriumConstant,
            cols: MoleculeGridSettings.cols,
            rows: initialRows,
            maxRows: GaseousReactionSettings.maxRows,
            startTime: 0,
            equilibriumTime: AqueousReactionSettings.forwardReactionTime
        )
        self.pumpModel = PumpViewModel(
            initialExtensionFactor: 1,
            divisions: 5,
            onDownPump: onPump
        )
    }

    @Published var componentWrapper: ReactionComponentsWrapper
    @Published var rows: CGFloat {
        didSet {
            componentWrapper.rows = GridMoleculesUtil.availableRows(for: rows)
        }
    }

    @Published var highlightedElements = HighlightedElements<GaseousScreenElement>()

    var components: ReactionComponents {
        componentWrapper.components
    }

    private func onPump() {
        componentWrapper.increment(molecule: .A, count: 1)
    }

    private(set) var pumpModel: PumpViewModel<CGFloat>!
}
