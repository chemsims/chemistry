//
// Reactions App
//
  

import SwiftUI

struct ConcentrationValueSlider: View {

    @Binding var initialConcentration: CGFloat
    @Binding var finalConcentration: CGFloat?
    let c1Disabled: Bool

    let c1Limits: InputLimits
    let c2Limits: InputLimits

    let settings: TimeChartGeometrySettings

    var body: some View {
        DualValueSlider(
            value1: $initialConcentration,
            value2: $finalConcentration,
            value1Limits: c1Limits,
            value2Limits: c2Limits,
            axis: settings.yAxis,
            orientation: .portrait,
            settings: settings,
            canSetInitialValue: true,
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

    /// Disabled changes to the t1 value
    let t1Disabled: Bool

    let t1Limits: InputLimits
    let t2Limits: InputLimits

    /// Layout settings
    let settings: TimeChartGeometrySettings

    var body: some View {
        DualValueSlider(
            value1: $t1,
            value2: $t2,
            value1Limits: t1Limits,
            value2Limits: t2Limits,
            axis: settings.xAxis,
            orientation: .landscape,
            settings: settings,
            canSetInitialValue: canSetInitialTime,
            value1Disabled: t1Disabled,
            value1IsLower: true
        )
    }
}
