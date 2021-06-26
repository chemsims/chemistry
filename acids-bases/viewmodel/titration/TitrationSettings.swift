//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct TitrationSettings {

    /// Minimum number of each ion molecules for the initial weak substance reaction.
    let minInitialIonBeakerMolecules: Int

    /// Height of the bar chart when the solution is neutral. That is, when pH = pOH = 7.
    let neutralSubstanceBarChartHeight: CGFloat

    /// Change in height of bars for the initial weak substance reactions, as a fraction
    /// of the initial substance bar height.
    let weakIonChangeInBarHeightFraction: CGFloat

    /// Value for the larger p-value at the end of the reaction
    /// For example, for an acid titration, this would be the value of pH at the end of the reaction,
    /// whereas for a basic titration it would be the value of pOH.
    let finalMaxPValue: CGFloat

    /// Maximum concentration of the initial strong substance
    let maxInitialStrongConcentration: CGFloat

    /// Minimum concentration of the initial strong substance
    let minInitialStrongConcentration: CGFloat

    /// Minimum concentration of the initial weak substance. Must be less than 0.25.
    let minInitialWeakConcentration: CGFloat

    let beakerVolumeFromRows: Equation

    static let standard = TitrationSettings(
        minInitialIonBeakerMolecules: 1,
        neutralSubstanceBarChartHeight: 0.15,
        weakIonChangeInBarHeightFraction: 0.1,
        finalMaxPValue: 13,
        maxInitialStrongConcentration: 0.5,
        minInitialStrongConcentration: 0.25,
        minInitialWeakConcentration: 0.15,
        beakerVolumeFromRows: LinearEquation(
            x1: CGFloat(AcidAppSettings.minBeakerRows),
            y1: 0.1,
            x2: CGFloat(AcidAppSettings.maxBeakerRows),
            y2: 0.6
        )
    )

    /// Bar chart height for concentration when adding strong substance.
    var barChartHeightFromConcentration: Equation {
        barChartHeightFromConcentration(
            concentrationThreshold: 1e-7,
            heightAtThreshold: neutralSubstanceBarChartHeight
        )
    }

    /// Returns an equation for bar chart height in terms of concentration.
    ///
    /// The bar chart scales from 0 to `heightAtThreshold` at the
    /// `concentrationThreshold`. From there, it scales to
    /// a height of 1 at a concentration of 1.
    private func barChartHeightFromConcentration(
        concentrationThreshold: CGFloat,
        heightAtThreshold: CGFloat
    ) -> Equation {
        SwitchingEquation(
            thresholdX: concentrationThreshold,
            underlyingLeft: LinearEquation(
                x1: 0,
                y1: 0,
                x2: concentrationThreshold,
                y2: heightAtThreshold
            ),
            underlyingRight: LinearEquation(
                x1: concentrationThreshold,
                y1: heightAtThreshold,
                x2: 1,
                y2: 1
            )
        )
    }
}
