//
// Reactions App
//
  

import SwiftUI

struct ConcentrationValueSlider: View {

    @Binding var initialConcentration: CGFloat
    @Binding var finalConcentration: CGFloat?

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
            absoluteMin: 0.1,
            absoluteMax: 1
        )
    }
}

struct TimeValueSlider: View {
    @Binding var t1: CGFloat
    @Binding var t2: CGFloat?

    let settings: TimeChartGeometrySettings
    let canSetInitialTime: Bool

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
            absoluteMin: 1,
            absoluteMax: ReactionSettings.maxTime
        )
    }
}
