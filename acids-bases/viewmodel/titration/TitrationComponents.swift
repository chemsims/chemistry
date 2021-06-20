//
// Reactions App
//

import SwiftUI
import ReactionsCore

class TitrationComponents: ObservableObject {

    init(
        substance: AcidOrBase,
        cols: Int,
        rows: Int,
        settings: TitrationSettings
    ) {
        self.substance = substance
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

    let volume: CGFloat = 0.1

    @Published private(set) var progress: CGFloat = 0
    @Published private(set) var beakerReaction: ReactingBeakerViewModel<ExtendedSubstancePart>
    @Published private(set) var reactionProgress: ReactionProgressChartViewModel<ExtendedSubstancePart>
    @Published private(set) var substanceCoords: BeakerMolecules

    let substance: AcidOrBase
    let settings: TitrationSettings
    let cols: Int
    let rows: Int

    var concentration: SubstanceValue<Equation> = .constant(ConstantEquation(value: 0))
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
        concentration = AcidConcentrationEquations.concentrations(
            forPartsOf: substance,
            initialSubstanceConcentration: CGFloat(substanceCoords.coords.count) / CGFloat(cols * rows)
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
    let beakerVolumeFromRows: Equation

    static let standard = TitrationSettings(
        initialIonMoleculeFraction: 0.1,
        minInitialIonBeakerMolecules: 1,
        beakerVolumeFromRows: LinearEquation(
            x1: CGFloat(AcidAppSettings.minBeakerRows),
            y1: 0.1,
            x2: CGFloat(AcidAppSettings.maxBeakerRows),
            y2: 0.6
        )
    )

    var minInitialSubstance: Int {
        let minInitial = CGFloat(minInitialIonBeakerMolecules)
        let fraction = initialIonMoleculeFraction
        guard fraction > 0 else { return 0 }

        return Int(ceil(minInitial / fraction))
    }
}
