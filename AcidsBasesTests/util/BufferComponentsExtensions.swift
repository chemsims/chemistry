//
// Reactions App
//

import CoreGraphics
@testable import AcidsBases

extension BufferComponentSettings {

    /// Returns a Settings instance with default values for each parameter
    static func withDefaults(
        changeInBarHeightAsFractionOfInitialSubstance: CGFloat = standard.changeInBarHeightAsFractionOfInitialSubstance,
        fractionOfFinalIonMolecules: CGFloat = standard.initialIonMoleculeFraction,
        minimumInitialIonCount: Int = standard.minimumInitialIonCount,
        finalSecondaryIonCount: Int = standard.finalSecondaryIonCount,
        minimumFinalPrimaryIonCount: Int = standard.minimumFinalPrimaryIonCount,
        maxFinalBeakerConcentration: CGFloat = 1
    ) -> BufferComponentSettings {
        BufferComponentSettings(
            changeInBarHeightAsFractionOfInitialSubstance: changeInBarHeightAsFractionOfInitialSubstance,
            initialIonMoleculeFraction: fractionOfFinalIonMolecules,
            minimumInitialIonCount: minimumInitialIonCount,
            finalSecondaryIonCount: finalSecondaryIonCount,
            minimumFinalPrimaryIonCount: minimumFinalPrimaryIonCount,
            maxFinalBeakerConcentration: maxFinalBeakerConcentration,
            reactionProgress: standard.reactionProgress
        )
    }
}
