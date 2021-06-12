//
// Reactions App
//

import CoreGraphics
@testable import acids_bases

extension BufferWeakSubstanceComponents.Settings {

    /// Returns a Settings instance with default values for each parameter
    static func withDefaults(
        changeInBarHeightAsFractionOfInitialSubstance: CGFloat = standard.changeInBarHeightAsFractionOfInitialSubstance,
        fractionOfFinalIonMolecules: CGFloat = standard.fractionOfFinalIonMolecules,
        minimumInitialIonCount: Int = standard.minimumInitialIonCount,
        finalSecondaryIonCount: Int = standard.finalSecondaryIonCount,
        minimumFinalPrimaryIonCount: Int = standard.minimumFinalPrimaryIonCount
    ) -> BufferWeakSubstanceComponents.Settings {
        BufferWeakSubstanceComponents.Settings(
            changeInBarHeightAsFractionOfInitialSubstance: changeInBarHeightAsFractionOfInitialSubstance,
            fractionOfFinalIonMolecules: fractionOfFinalIonMolecules,
            minimumInitialIonCount: minimumInitialIonCount,
            finalSecondaryIonCount: finalSecondaryIonCount,
            minimumFinalPrimaryIonCount: minimumFinalPrimaryIonCount
        )
    }
}
