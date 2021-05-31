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
        self.substance = initialSubstance
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
    @Published var substance: AcidOrBase
    @Published var selectedSubstances = AcidOrBaseMap<AcidOrBase?>.constant(nil)
    @Published var availableSubstances = AcidOrBase.strongAcids
    @Published var inputState = InputState.none

    private(set) var addMoleculesModel: MultiContainerShakeViewModel<AcidOrBaseType>!


    func increment() {
        components.increment(count: 1)
    }

    enum InputState {
        case chooseSubstance(type: AcidOrBaseType)
        case none, setWaterLevel, addSubstance

        var isChoosingSubstance: Bool {
            if case .chooseSubstance = self {
                return true
            }
            return false
        }
    }
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
    var chooseSubstanceBinding: Binding<AcidOrBase> {

        let defaultSubstance = availableSubstances.first!
        if case let .chooseSubstance(type) = inputState {
            return Binding(
                get: { [self] in
                    selectedSubstances.value(for: type) ?? defaultSubstance
                },
                set: { [self] in
                    selectedSubstances = selectedSubstances.updating(with: $0, for: type)
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
