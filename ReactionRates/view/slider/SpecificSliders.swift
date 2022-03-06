//
// Reactions App
//

import SwiftUI

struct ConcentrationValueSlider: View {

    @Binding var initialConcentration: CGFloat
    @Binding var finalConcentration: CGFloat?

    /// Disabled both inputs
    let disabled: Bool

    let c1Disabled: Bool

    let c1Limits: InputLimits
    let c2Limits: InputLimits

    let reactant: String
    let settings: ReactionRateChartLayoutSettings

    var body: some View {
        DualValueSlider(
            value1: $initialConcentration,
            value2: $finalConcentration,
            value1Limits: c1Limits,
            value2Limits: c2Limits,
            value1Label: "input for c1",
            value2Label: "input for c2",
            axis: settings.yAxis,
            orientation: .vertical,
            settings: settings,
            canSetInitialValue: true,
            disabled: disabled,
            value1Disabled: c1Disabled,
            value1IsLower: false
        )
    }
}

struct TimeValueSlider: View {
    @Binding var t1: CGFloat
    @Binding var t2: CGFloat?

    /// Hides the t1 input entirely
    let canSetInitialTime: Bool

    /// Disabled both inputs
    let disabled: Bool

    /// Disabled changes to the t1 value
    let t1Disabled: Bool

    let t1Limits: InputLimits
    let t2Limits: InputLimits

    /// Layout settings
    let settings: ReactionRateChartLayoutSettings

    var body: some View {
        DualValueSlider(
            value1: $t1,
            value2: $t2,
            value1Limits: t1Limits,
            value2Limits: t2Limits,
            value1Label: "input for t1",
            value2Label: "input for t2",
            axis: settings.xAxis,
            orientation: .horizontal,
            settings: settings,
            canSetInitialValue: canSetInitialTime,
            disabled: disabled,
            value1Disabled: t1Disabled,
            value1IsLower: true
        )
    }
}
