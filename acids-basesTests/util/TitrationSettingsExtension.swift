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
        neutralSubstanceBarChartHeight: CGFloat = standard.neutralSubstanceBarChartHeight,
        weakIonChangeInBarHeightFraction: CGFloat = standard.weakIonChangeInBarHeightFraction,
        finalMaxPValue: CGFloat = standard.finalMaxPValue,
        beakerVolumeFromRows: Equation = standard.beakerVolumeFromRows
    ) -> TitrationSettings {
        self.init(
            initialIonMoleculeFraction: initialIonMoleculeFraction,
            minInitialIonBeakerMolecules: minInitialIonBeakerMolecules,
            neutralSubstanceBarChartHeight: neutralSubstanceBarChartHeight,
            weakIonChangeInBarHeightFraction: weakIonChangeInBarHeightFraction,
            finalMaxPValue: finalMaxPValue,
            beakerVolumeFromRows: beakerVolumeFromRows
        )
    }
}
