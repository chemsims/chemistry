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

    @Published var chartOffset: CGFloat = 0
    @Published var activeChartIndex: Int? = nil
    @Published var canSetCurrentTime = false
    @Published var canSetChartIndex = false
    @Published var showConcentrationLines = false
    @Published var showQuotientLine = false


    var components: ReactionComponents {
        componentWrapper.components
    }

    var maxQuotient: CGFloat {
        10
    }

    var equilibriumQuotient: CGFloat {
        10
    }

    private func onPump() {
        objectWillChange.send()
        componentWrapper.increment(molecule: selectedPumpReactant.molecule, count: 1)
    }

    private(set) var pumpModel: PumpViewModel<CGFloat>!
}
