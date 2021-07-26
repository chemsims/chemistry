//
// Reactions App
//

import CoreGraphics
import ReactionsCore
@testable import AcidsBases

extension TitrationSettings {

    /// Returns a settings instance using the standard settings for default arguments
    static func withDefaults(
        minInitialIonBeakerMolecules: Int = standard.minInitialIonBeakerMolecules,
        neutralSubstanceBarChartHeight: CGFloat = standard.neutralSubstanceBarChartHeight,
        weakIonChangeInBarHeightFraction: CGFloat = standard.weakIonChangeInBarHeightFraction,
        finalMaxPValue: CGFloat = standard.finalMaxPValue,
        maxInitialStrongConcentration: CGFloat = standard.maxInitialStrongConcentration,
        minInitialStrongConcentration: CGFloat = standard.minInitialStrongConcentration,
        minInitialWeakConcentration: CGFloat = standard.minInitialWeakConcentration,
        beakerVolumeFromRows: Equation = standard.beakerVolumeFromRows
    ) -> TitrationSettings {
        self.init(
            minInitialIonBeakerMolecules: minInitialIonBeakerMolecules,
            neutralSubstanceBarChartHeight: neutralSubstanceBarChartHeight,
            weakIonChangeInBarHeightFraction: weakIonChangeInBarHeightFraction,
            finalMaxPValue: finalMaxPValue,
            maxInitialStrongConcentration: maxInitialStrongConcentration,
            minInitialStrongConcentration: minInitialStrongConcentration,
            minInitialWeakConcentration: minInitialWeakConcentration,
            beakerVolumeFromRows: beakerVolumeFromRows
        )
    }
}
