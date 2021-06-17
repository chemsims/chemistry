//
// Reactions App
//

import SwiftUI
import ReactionsCore

class TitrationComponents: ObservableObject {

    init(cols: Int, rows: Int) {
        self.substanceCoords = BeakerMolecules(coords: [], color: .red, label: "")
        self.cols = cols
        self.rows = rows
        self.reactionProgress = .init(
            molecules: Self.initialMoleculeDefinitions,
            settings: .init(maxMolecules: AcidAppSettings.maxReactionProgressMolecules),
            timing: .init()
        )
        self.beakerReaction = .init(
            initial: Self.initialBeakerMolecules,
            cols: cols,
            rows: rows
        )
    }

    @Published private(set) var beakerReaction: ReactingBeakerViewModel<ExtendedSubstancePart>
    @Published private(set) var reactionProgress: ReactionProgressChartViewModel<ExtendedSubstancePart>
    @Published private(set) var substanceCoords: BeakerMolecules

    let cols: Int
    let rows: Int
}

// MARK: Incrementing substance
extension TitrationComponents {
    func incrementStrongAcid(count: Int) {
        substanceCoords.coords = GridCoordinateList.addingRandomElementsTo(
            grid: substanceCoords.coords,
            count: count,
            cols: cols,
            rows: rows
        )
    }
}

// MARK: Data types
extension TitrationComponents {

    static let initialMoleculeDefinitions = EnumMap<ExtendedSubstancePart, MoleculeDefinition> {
        $0.moleculeDefinition
    }

    static let initialBeakerMolecules = EnumMap<ExtendedSubstancePart, BeakerMolecules> {
        $0.beakerMolecules
    }

    typealias MoleculeDefinition = ReactionProgressChartViewModel<ExtendedSubstancePart>.MoleculeDefinition

    enum ExtendedSubstancePart: String, CaseIterable {
        case substance, secondaryIon, hydrogen, hydroxide

        var moleculeDefinition: MoleculeDefinition {
            MoleculeDefinition(
                label: "",
                columnIndex: 0,
                initialCount: 1,
                color: .red
            )
        }

        var beakerMolecules: BeakerMolecules {
            BeakerMolecules(
                coords: [],
                color: .red,
                label: ""
            )
        }
    }
}
