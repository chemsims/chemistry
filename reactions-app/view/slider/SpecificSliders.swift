//
// Reactions App
//
  

import SwiftUI

struct ConcentrationValueSlider: View {

    @Binding var initialConcentration: CGFloat
    @Binding var finalConcentration: CGFloat?
    let c1Disabled: Bool

    let settings: TimeChartGeometrySettings

    var body: some View {
        DualValueSlider(
            value1: $initialConcentration,
            value2: $finalConcentration,
            value1PreviousHandle: settings.minFinalConcentration,
            value1NextHandle: nil,
            value2PreviousHandle: nil,
            value2NextHandle: initialConcentration,
            axis: settings.yAxis,
            orientation: .portrait,
            settings: settings,
            canSetInitialValue: true,
            absoluteMin: ReactionSettings.minCInput,
            absoluteMax: ReactionSettings.maxCInput,
            value1Disabled: c1Disabled
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

    let settings: TimeChartGeometrySettings

    var body: some View {
        DualValueSlider(
            value1: $t1,
            value2: $t2,
            value1PreviousHandle: nil,
            value1NextHandle: canSetInitialTime ? settings.minFinalTime : nil,
            value2PreviousHandle: canSetInitialTime ? t1 : nil,
            value2NextHandle: nil,
            axis: settings.xAxis,
            orientation: .landscape,
            settings: settings,
            canSetInitialValue: canSetInitialTime,
            absoluteMin: canSetInitialTime ? ReactionSettings.minT1Input : ReactionSettings.minT2Input,
            absoluteMax: ReactionSettings.maxTInput,
            value1Disabled: t1Disabled
        )
    }
}
