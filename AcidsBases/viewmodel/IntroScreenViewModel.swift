//
// Reactions App
//

import SwiftUI
import ReactionsCore

class IntroScreenViewModel: ObservableObject {

    init(
        substancePersistence: AcidOrBasePersistence,
        namePersistence: NamePersistence
    ) {
        let initialRows = AcidAppSettings.initialRows
        let initialSubstance = AcidOrBase.strongAcids.first!
        self.substancePersistence = substancePersistence
        self.rows = CGFloat(initialRows)
        self.components = IntroScreenComponents(
            substance: initialSubstance,
            cols: MoleculeGridSettings.cols,
            rows: initialRows
        )
        self.addMoleculesModel = MultiContainerShakeViewModel(
            canAddMolecule: { _ in self.canAddMolecule },
            addMolecules: self.increment,
            useBufferWhenAddingMolecules: DeviceInfo.shouldThrottleAnimationRateIfNeeded()
        )
        self.navigation = IntroNavigationModel.model(self, namePersistence: namePersistence)
    }

    let substancePersistence: AcidOrBasePersistence

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

    func increment(type: AcidOrBaseType, count: Int) {
        if !highlights.elements.isEmpty {
            highlights.clear()
        }
        guard components.substance.type == type,
              inputState == .addSubstance(type: type) else {
            return
        }
        components.increment(count: count)
        handlePostIncrementStatement()
        goNextIfNeededPostIncrement()
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
        if let statement = getPostIncrementStatement() {
            if self.statement != statement {
                self.statement = statement
                UIAccessibility.post(
                    notification: .announcement,
                    argument: statement.label
                )
            }
        }
    }

    private func getPostIncrementStatement() -> [TextLine]? {
        if case let .addSubstance(type) = inputState,
           components.fractionSubstanceAdded >= 0.5 {
            let substance = getSubstance(forType: type)

            switch type {
            case .strongAcid:
                return IntroStatements.midAddingStrongAcid(substance: substance)
            case .strongBase:
                return IntroStatements.midAddingStrongBase(substance: substance)
            case .weakAcid:
                return IntroStatements.midAddingWeakAcid(substance: substance)
            case .weakBase:
                return IntroStatements.midAddingWeakBase(substance: substance)
            }

        }
        return nil
    }

    private func goNextIfNeededPostIncrement() {
        if case .addSubstance(_) = inputState, !components.canAddSubstance {
            next()
            UIAccessibility.post(
                notification: .announcement,
                argument: statement.label
            )
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

            if type == .strongAcid {
                substancePersistence.saveStrongAcid(substance)
            } else if type == .strongBase {
                substancePersistence.saveStrongBase(substance)
            }
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
