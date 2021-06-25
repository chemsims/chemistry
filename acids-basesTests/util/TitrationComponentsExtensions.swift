//
// Reactions App
//

import CoreGraphics
import ReactionsCore
@testable import acids_bases

extension TitrationStrongSubstancePreparationModel {

    /// Returns an instance using default arguments, and a 10x10 grid
    convenience init(
        substance: AcidOrBase = .strongAcids.first!,
        settings: TitrationSettings = .standard
    ) {
        self.init(
            substance: substance,
            titrant: "KOH",
            cols: 10,
            rows: 10,
            settings: settings
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
        substance: AcidOrBase = .weakAcids.first!,
        settings: TitrationSettings = .standard
    ) {
        self.init(
            substance: substance,
            cols: 10,
            rows: 10,
            settings: settings
        )
    }
}

extension TitrationStrongSubstancePreparationModel {
    var currentPValues: EnumMap<TitrationEquationTerm.PValue, CGFloat> {
        equationData.pValues.map { $0.getY(at: CGFloat(substanceAdded)) }
    }

    var currentConcentration: EnumMap<TitrationEquationTerm.Concentration, CGFloat> {
        concentration.map { $0.getY(at: CGFloat(substanceAdded)) }
    }

    var currentMolarity: EnumMap<TitrationEquationTerm.Molarity, CGFloat> {
        molarity.map { $0.getY(at: CGFloat(substanceAdded)) }
    }

    var currentMoles: EnumMap<TitrationEquationTerm.Moles, CGFloat> {
        moles.map { $0.getY(at: CGFloat(substanceAdded)) }
    }

    var currentVolumes: EnumMap<TitrationEquationTerm.Volume, CGFloat> {
        volume.map { $0.getY(at: CGFloat(substanceAdded)) }
    }
}

extension TitrationStrongSubstancePreEPModel {
    var currentPValues: EnumMap<TitrationEquationTerm.PValue, CGFloat> {
        equationData.pValues.map { $0.getY(at: CGFloat(titrantAdded)) }
    }

    var currentConcentration: EnumMap<TitrationEquationTerm.Concentration, CGFloat> {
        concentration.map { $0.getY(at: CGFloat(titrantAdded)) }
    }

    var currentMoles: EnumMap<TitrationEquationTerm.Moles, CGFloat> {
        moles.map { $0.getY(at: CGFloat(titrantAdded)) }
    }
}

extension TitrationStrongSubstancePostEPModel {
    var currentPValues: EnumMap<TitrationEquationTerm.PValue, CGFloat> {
        pValues.map { $0.getY(at: CGFloat(titrantAdded)) }
    }

    var currentConcentration: EnumMap<TitrationEquationTerm.Concentration, CGFloat> {
        concentration.map { $0.getY(at: CGFloat(titrantAdded)) }
    }
}
