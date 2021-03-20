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
            beakerCols: MoleculeGridSettings.cols,
            beakerRows: initialRows,
            maxBeakerRows: GaseousReactionSettings.maxRows,
            dynamicGridCols: EquilibriumGridSettings.cols,
            dynamicGridRows: EquilibriumGridSettings.rows,
            startTime: 0,
            equilibriumTime: AqueousReactionSettings.forwardReactionTime,
            maxC: AqueousReactionSettings.ConcentrationInput.maxInitial
        )
        self.pumpModel = PumpViewModel(
            initialExtensionFactor: 1,
            divisions: 5,
            onDownPump: onPump
        )
    }

    @Published var currentTime: CGFloat = 0
    @Published var componentWrapper: ReactionComponentsWrapper
    @Published var rows: CGFloat {
        didSet {
            objectWillChange.send()
            componentWrapper.beakerRows = GridUtil.availableRows(for: rows)
        }
    }

    @Published var highlightedElements = HighlightedElements<GaseousScreenElement>()
    @Published var selectedPumpReactant = AqueousMoleculeReactant.A

    var components: ReactionComponents {
        componentWrapper.components
    }

    private func onPump() {
        objectWillChange.send()
        componentWrapper.increment(molecule: selectedPumpReactant.molecule, count: 1)
    }

    private(set) var pumpModel: PumpViewModel<CGFloat>!
}
