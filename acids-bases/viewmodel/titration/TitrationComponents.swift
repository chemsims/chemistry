//
// Reactions App
//

import SwiftUI
import ReactionsCore

class TitrationComponents: ObservableObject {

    init(
        cols: Int,
        rows: Int,
        settings: TitrationSettings
    ) {
        self.settings = settings
        self.cols = cols
        self.rows = rows
        self.substanceCoords = BeakerMolecules(coords: [], color: .red, label: "")
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

    let settings: TitrationSettings
    let cols: Int
    let rows: Int
}

// MARK: Beaker coords
extension TitrationComponents {
    var ionCoords: [AnimatingBeakerMolecules] {
        [
            coordForIon(.red, index: 0),
            coordForIon(.purple, index: 1)
        ]
    }

    private func coordForIon(_ color: Color, index: Int) -> AnimatingBeakerMolecules {
        let startCoordIndex = index * finalIonCoordCount
        let endCoordIndex = max(startCoordIndex, startCoordIndex + finalIonCoordCount - 1)

        var coords = [GridCoordinate]()
        if endCoordIndex < substanceCoords.coords.endIndex {
            coords = Array(substanceCoords.coords[startCoordIndex...endCoordIndex])
        }

        return AnimatingBeakerMolecules(
            molecules: BeakerMolecules(
                coords: coords,
                color: color,
                label: ""
            ),
            fractionToDraw: LinearEquation(m: 1, x1: 0, y1: 0)
        )
    }

    private var finalIonCoordCount: Int {
        Int(settings.initialIonMoleculeFraction * CGFloat(substanceCoords.coords.count))
    }
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

// MARK: Input limits
extension TitrationComponents {
    var minAcidToAdd: Int {
        let minInitial = CGFloat(settings.minInitialIonBeakerMolecules)
        let fraction = settings.initialIonMoleculeFraction
        return fraction == 0 ? 0 : Int(minInitial / fraction)
    }
}

struct TitrationSettings {
    let initialIonMoleculeFraction: CGFloat
    let minInitialIonBeakerMolecules: Int

    static let standard = TitrationSettings(
        initialIonMoleculeFraction: 0.1,
        minInitialIonBeakerMolecules: 1
    )

    var minInitialSubstance: Int {
        let minInitial = CGFloat(minInitialIonBeakerMolecules)
        let fraction = initialIonMoleculeFraction
        guard fraction > 0 else { return 0 }

        return Int(ceil(minInitial / fraction))
    }
}
