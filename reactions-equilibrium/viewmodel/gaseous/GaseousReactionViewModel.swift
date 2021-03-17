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
        self.components = ForwardAqueousReactionComponents(
            coefficients: initialReaction.coefficients,
            equilibriumConstant: initialReaction.equilibriumConstant,
            availableCols: MoleculeGridSettings.cols,
            availableRows: initialRows,
            maxRows: GaseousReactionSettings.maxRows
        )
        self.pumpModel = PumpViewModel(
            initialExtensionFactor: 1,
            divisions: 5,
            onDownPump: onPump
        )
    }

    @Published var components: AqueousReactionComponents
    @Published var rows: CGFloat {
        didSet {
            components.availableRows = GridMoleculesUtil.availableRows(for: rows)
        }
    }

    @Published var highlightedElements = HighlightedElements<GaseousScreenElement>()

    private var count = 0

    private func onPump() {
        count += 1
        components.increment(molecule: .A, count: 1)
    }

    private(set) var pumpModel: PumpViewModel<CGFloat>!
}
