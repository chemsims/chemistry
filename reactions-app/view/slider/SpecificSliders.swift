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
            value1PreviousHandle: 0.1,
            value1NextHandle: nil,
            value2PreviousHandle: nil,
            value2NextHandle: initialConcentration,
            axis: settings.yAxis,
            orientation: .portrait,
            settings: settings
        )
    }
}

struct TimeValueSlider: View {
    @Binding var t1: CGFloat
    @Binding var t2: CGFloat?

    let settings: TimeChartGeometrySettings

    var body: some View {
        DualValueSlider(
            value1: $t1,
            value2: $t2,
            value1PreviousHandle: nil,
            value1NextHandle: 20,
            value2PreviousHandle: t1,
            value2NextHandle: nil,
            axis: settings.xAxis,
            orientation: .landscape,
            settings: settings
        )
    }
}
