//
// Reactions App
//

import CoreGraphics
import ReactionsCore
@testable import acids_bases

extension TitrationStrongSubstancePreparationModel {

    /// Returns an instance using default arguments, and a 10x10 grid
    convenience init(
        substance: AcidOrBase,
        settings: TitrationSettings = .standard,
        maxReactionProgressMolecules: Int = AcidAppSettings.maxReactionProgressMolecules
    ) {
        self.init(
            substance: substance,
            titrant: .potassiumHydroxide,
            cols: 10,
            rows: 10,
            settings: settings,
            maxReactionProgressMolecules: maxReactionProgressMolecules
        )
    }

    static func concentrationOfIncreasingMolecule(
        afterIncrementing count: Int,
        gridSize: Int
    ) -> CGFloat {
        LinearEquation(
            x1: 0,
            y1: 1e-7,
            x2: CGFloat(gridSize),
            y2: 1
        ).getY(at: CGFloat(count))
    }
}

extension TitrationWeakSubstancePreparationModel {
    /// Returns an instance using default arguments, and a 10x10 grid
    convenience init(
        substance: AcidOrBase,
        settings: TitrationSettings = .standard,
        maxReactionProgressMolecules: Int = AcidAppSettings.maxReactionProgressMolecules
    ) {
        self.init(
            substance: substance,
            titrant: .potassiumHydroxide,
            cols: 10,
            rows: 10,
            settings: settings,
            maxReactionProgressMolecules: maxReactionProgressMolecules
        )
    }

    var currentPValues: EnumMap<TitrationEquationTerm.PValue, CGFloat> {
        equationData.pValues.map { $0.getY(at: reactionProgress) }
    }
}

extension TitrationStrongSubstancePreparationModel {
    var currentPValues: EnumMap<TitrationEquationTerm.PValue, CGFloat> {
        equationData.pValues.map { $0.getY(at: CGFloat(substanceAdded)) }
    }

    var currentVolumes: EnumMap<TitrationEquationTerm.Volume, CGFloat> {
        equationData.volume.map { $0.getY(at: CGFloat(substanceAdded)) }
    }
}

extension TitrationStrongSubstancePreEPModel {
    var currentPValues: EnumMap<TitrationEquationTerm.PValue, CGFloat> {
        equationData.pValues.map { $0.getY(at: CGFloat(titrantAdded)) }
    }

    var currentConcentration: EnumMap<TitrationEquationTerm.Concentration, CGFloat> {
        equationData.concentration.map { $0.getY(at: CGFloat(titrantAdded)) }
    }

    var currentMoles: EnumMap<TitrationEquationTerm.Moles, CGFloat> {
        equationData.moles.map { $0.getY(at: CGFloat(titrantAdded)) }
    }
}

extension TitrationStrongSubstancePostEPModel {
    var currentPValues: EnumMap<TitrationEquationTerm.PValue, CGFloat> {
        equationData.pValues.map { $0.getY(at: CGFloat(titrantAdded)) }
    }

    var concentration: EnumMap<TitrationEquationTerm.Concentration, Equation> {
        equationData.concentration
    }

    var moles: EnumMap<TitrationEquationTerm.Moles, Equation> {
        equationData.moles
    }

    var volume: EnumMap<TitrationEquationTerm.Volume, Equation> {
        equationData.volume
    }

    // Note molarity doesn't actually change post EP, but we pass in the titrant added to the
    // equation anyway
    var currentMolarity: EnumMap<TitrationEquationTerm.Molarity, CGFloat> {
        equationData.molarity.map {
            $0.getY(at: CGFloat(titrantAdded))
        }
    }

    var currentConcentration: EnumMap<TitrationEquationTerm.Concentration, CGFloat> {
        concentration.map { $0.getY(at: CGFloat(titrantAdded)) }
    }

    var currentMoles: EnumMap<TitrationEquationTerm.Moles, CGFloat> {
        moles.map { $0.getY(at: CGFloat(titrantAdded)) }
    }

    var currentVolumes: EnumMap<TitrationEquationTerm.Volume, CGFloat> {
        volume.map { $0.getY(at: CGFloat(titrantAdded)) }
    }
}
