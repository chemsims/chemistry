//
// Reactions App
//

import SwiftUI
import ReactionsCore

class IntroScreenViewModel: ObservableObject {

    init() {
        let initialRows = AcidAppSettings.initialRows
        let initialSubstance = AcidOrBase.strongAcid(
            secondaryIon: .A,
            color: .blue
        )
        self.rows = CGFloat(initialRows)
        self.components = IntroScreenComponents(
            substance: initialSubstance,
            cols: MoleculeGridSettings.cols,
            rows: initialRows
        )
        self.addMoleculesModel = MultiContainerShakeViewModel(
            canAddMolecule: { _ in true },
            addMolecules: { _, _ in self.components.increment(count: 1) }
        )
        self.navigation = IntroNavigationModel.model(self)
    }

    private(set) var navigation: NavigationModel<IntroScreenState>?
    @Published var statement: [TextLine] = []
    @Published var components: IntroScreenComponents
    @Published var rows: CGFloat {
        didSet {
            components.rows = GridCoordinateList.availableRows(for: rows)
        }
    }
    @Published var selectedSubstances = AcidOrBaseMap<AcidOrBase?>.constant(nil)
    @Published var availableSubstances = AcidOrBase.strongAcids
    @Published var inputState = InputState.none

    private(set) var addMoleculesModel: MultiContainerShakeViewModel<AcidOrBaseType>!

    func increment() {
        components.increment(count: 1)
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
    }

    private let cols = MoleculeGridSettings.cols

    private var componentStates = [IntroScreenComponents.State]()
}

// MARK: Navigation
extension IntroScreenViewModel {
    func next() {
        navigation?.next()
    }

    func back() {
        navigation?.back()
    }
}

// MARK: Substance selection
extension IntroScreenViewModel {

    func addNewComponents(type: AcidOrBaseType) {
        let substance = selectedSubstances.value(for: type) ?? AcidOrBase.substances(forType: type).first!
        let currentState = components.state

        componentStates.append(currentState)

        withAnimation(.easeOut(duration: 0.5)) {
            components.substance = substance
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
    }

    func setSubstance(_ substance: AcidOrBase?, type: AcidOrBaseType) {
        self.selectedSubstances = selectedSubstances.updating(with: substance, for: type)
        if let substance = substance {
            self.components.substance = substance
        }
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
