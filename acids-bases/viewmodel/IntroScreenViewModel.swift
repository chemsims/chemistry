//
// Reactions App
//

import SwiftUI
import ReactionsCore

class IntroScreenViewModel: ObservableObject {

    init(namePersistence: NamePersistence) {
        let initialRows = AcidAppSettings.initialRows
        let initialSubstance = AcidOrBase.strongAcids.first!
        self.rows = CGFloat(initialRows)
        self.components = IntroScreenComponents(
            substance: initialSubstance,
            cols: MoleculeGridSettings.cols,
            rows: initialRows
        )
        self.addMoleculesModel = MultiContainerShakeViewModel(
            canAddMolecule: { _ in self.canAddMolecule },
            addMolecules: self.increment
        )
        self.navigation = IntroNavigationModel.model(self, namePersistence: namePersistence)
    }

    private(set) var navigation: NavigationModel<IntroScreenState>?
    @Published var statement: [TextLine] = []
    @Published var components: IntroScreenComponents
    @Published var rows: CGFloat {
        didSet {
            components.rows = GridCoordinateList.availableRows(for: rows)
            if highlights.elements == [.waterSlider] {
                highlights.clear()
            }
        }
    }
    @Published var selectedSubstances = AcidOrBaseMap<AcidOrBase?>.constant(nil)
    @Published var availableSubstances = AcidOrBase.strongAcids
    @Published var inputState = InputState.none
    @Published var graphView = GraphView.concentration

    @Published var highlights = HighlightedElements<IntroScreenElement>()

    private(set) var addMoleculesModel: MultiContainerShakeViewModel<AcidOrBaseType>!

    private func increment(type: AcidOrBaseType, count: Int) {
        guard components.substance.type == type,
              inputState == .addSubstance(type: type) else {
            return
        }
        components.increment(count: count)
        handlePostIncrementStatement()
    }

    private let cols = MoleculeGridSettings.cols

    private var componentStates = [IntroScreenComponents.State]()

    private var canAddMolecule: Bool {
        components.fractionSubstanceAdded < 1
    }

    enum InputState: Equatable {
        case chooseSubstance(type: AcidOrBaseType)
        case addSubstance(type: AcidOrBaseType)
        case none, setWaterLevel

        var isChoosingSubstance: Bool {
            if case .chooseSubstance = self {
                return true
            }
            return false
        }

        var isAddingSubstance: Bool {
            if case .addSubstance = self {
                return true
            }
            return false
        }
    }

    enum GraphView {
        case ph, concentration
    }
}

// MARK: Navigation
extension IntroScreenViewModel {
    func next() {
        guard canGoNext else {
            return
        }
        navigation?.next()
    }

    func back() {
        navigation?.back()
    }

    private func handlePostIncrementStatement() {
        if case let .addSubstance(type) = inputState,
           components.fractionSubstanceAdded >= 0.5 {
            let substance = getSubstance(forType: type)
            let statement: [TextLine]
            switch type {
            case .strongAcid: statement = IntroStatements.midAddingStrongAcid(substance: substance)
            case .strongBase: statement = IntroStatements.midAddingStrongBase(substance: substance)
            case .weakAcid: statement = IntroStatements.midAddingWeakAcid(substance: substance)
            case .weakBase: statement = IntroStatements.midAddingWeakBase(substance: substance)
            }
            self.statement = statement
        }
    }

    var canGoNext: Bool {
        if inputState.isAddingSubstance {
            return components.fractionSubstanceAdded >= 0.5
        }
        return true
    }
}

// MARK: Substance selection
extension IntroScreenViewModel {

    func addNewComponents(type: AcidOrBaseType) {
        let currentState = components.state

        componentStates.append(currentState)

        withAnimation(.easeOut(duration: 0.5)) {
            components.substance = getSubstance(forType: type)
            components.reset()
            rows = CGFloat(AcidAppSettings.initialRows)
        }
    }

    func popLastComponent() {
        guard !componentStates.isEmpty else {
            return
        }
        let lastState = componentStates.removeLast()
        withAnimation(.easeOut(duration: 0.5)) {
            components.restore(from: lastState)
            rows = CGFloat(components.rows)
        }
        availableSubstances = AcidOrBase.substances(forType: lastState.substance.type)
    }

    func setSubstance(_ substance: AcidOrBase?, type: AcidOrBaseType) {
        self.selectedSubstances = selectedSubstances.updating(with: substance, for: type)
        if let substance = substance {
            self.components.substance = substance
        }
    }

    private func getSubstance(forType type: AcidOrBaseType) -> AcidOrBase {
        selectedSubstances.value(for: type) ?? AcidOrBase.substances(forType: type).first!
    }

    var chooseSubstanceBinding: Binding<AcidOrBase> {
        let defaultSubstance = availableSubstances.first!
        if case let .chooseSubstance(type) = inputState {
            return Binding(
                get: { [self] in
                    selectedSubstances.value(for: type) ?? defaultSubstance
                },
                set: { [self] in
                    setSubstance($0, type: type)
                }
            )
        }

        // Return a dummy binding
        return Binding(
            get: { defaultSubstance },
            set: { _ in }
        )
    }
}
