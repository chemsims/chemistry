//
// Reactions App
//

import SwiftUI

struct SliderIndicator: View {
    let value1: CGFloat
    let value2: CGFloat?
    let showInitialValue: Bool
    let settings: TimeChartGeometrySettings
    let axis: AxisPositionCalculations<CGFloat>
    let orientation: Orientation

    var body: some View {
        ZStack {
            if showInitialValue {
                makeIndicator(value: value1, disabled: value2 != nil)
            }
            if value2 != nil {
                makeIndicator(value: value2!, disabled: false)
            }
        }
    }

    private func makeIndicator(
        value: CGFloat,
        disabled: Bool
    ) -> some View {
        CustomSlider(
            value: .constant(value),
            axis: axis,
            handleThickness: settings.indicatorThickness,
            handleColor: disabled ? Color.gray : Color.orangeAccent,
            handleCornerRadius: 0,
            barThickness: 0,
            barColor: .black,
            orientation: orientation,
            includeFill: false
        ).disabled(true)
    }
}
