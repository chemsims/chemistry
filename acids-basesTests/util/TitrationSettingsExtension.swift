//
// Reactions App
//

import CoreGraphics
import ReactionsCore
@testable import acids_bases

extension TitrationSettings {

    /// Returns a settings instance using the standard settings for default arguments
    static func withDefaults(
        initialIonMoleculeFraction: CGFloat = standard.initialIonMoleculeFraction,
        minInitialIonBeakerMolecules: Int = standard.minInitialIonBeakerMolecules,
        beakerVolumeFromRows: Equation = standard.beakerVolumeFromRows
    ) -> TitrationSettings {
        self.init(
            initialIonMoleculeFraction: initialIonMoleculeFraction,
            minInitialIonBeakerMolecules: minInitialIonBeakerMolecules,
            beakerVolumeFromRows: beakerVolumeFromRows
        )
    }
}
