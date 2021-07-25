//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct SliderIndicator: View {
    let value1: CGFloat
    let value2: CGFloat?
    let showInitialValue: Bool
    let settings: ReactionRateChartLayoutSettings
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
            orientation: orientation,
            includeFill: false,
            settings: settings.indicatorSettings,
            disabled: false,
            handleColor: disabled ? Color.gray : Color.orangeAccent,
            barColor: .black,
            useHaptics: false
        )
        .disabled(true)
    }
}
