//
// Reactions App
//
  

import SwiftUI


struct DualValueSlider: View {

    @Binding var value1: CGFloat
    @Binding var value2: CGFloat?

    let value1Limits: InputLimits
    let value2Limits: InputLimits

    let axis: AxisPositionCalculations<CGFloat>
    let orientation: Orientation
    let settings: TimeChartGeometrySettings
    let canSetInitialValue: Bool

    let value1Disabled: Bool
    let value1IsLower: Bool

    var body: some View {
        ZStack {
            if (canSetInitialValue) {
                slider(
                    binding: $value1,
                    axis: axis(limits: value1Limits),
                    disabled: value1Disabled,
                    showBar: true
                )
            }

            if (value2 != nil) {
                slider(
                    binding: value2UnsafeBinding,
                    axis: axis(limits: value2Limits),
                    disabled: false,
                    showBar: canSetInitialValue ? false : true
                )
            }
        }
    }

    private func slider(
        binding: Binding<CGFloat>,
        axis: AxisPositionCalculations<CGFloat>,
        disabled: Bool,
        showBar: Bool
    ) -> some View {
        CustomSlider(
            value: binding,
            axis: axis,
            handleThickness: settings.handleThickness,
            handleColor: disabled ? Color.gray : Color.orangeAccent,
            handleCornerRadius: settings.handleCornerRadius,
            barThickness: showBar ? settings.barThickness : 0,
            barColor: Color.black,
            orientation: orientation,
            includeFill: false
        ).disabled(disabled)
    }

    private func axis(limits: InputLimits) -> AxisPositionCalculations<CGFloat> {
        LimitConstraints.constrain(
            limit: limits,
            axis: axis,
            spacing: settings.handleThickness + settings.sliderMinSpacing
        )
    }

    private var value2UnsafeBinding: Binding<CGFloat> {
        Binding(get: { value2! }, set: { value2 = $0 })
    }
}
