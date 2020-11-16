//
// Reactions App
//
  

import SwiftUI

struct DualValueSlider: View {
    @Binding var value1: CGFloat
    @Binding var value2: CGFloat?

    let value1PreviousHandle: CGFloat?
    let value1NextHandle: CGFloat?
    let value2PreviousHandle: CGFloat?
    let value2NextHandle: CGFloat?

    let axis: AxisPositionCalculations<CGFloat>
    let orientation: Orientation
    let settings: TimeChartGeometrySettings

    var body: some View {
        ZStack {
            slider(
                binding: $value1,
                axis: axis(
                    minValue: value1PreviousHandle,
                    maxValue: value1NextHandle
                ),
                disabled: value2 != nil,
                showBar: true
            )
            if (value2 != nil) {
                slider(
                    binding: value2UnsafeBinding,
                    axis: axis(
                        minValue: value2PreviousHandle,
                        maxValue: value2NextHandle
                    ),
                    disabled: false,
                    showBar: false
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
            orientation: orientation
        ).disabled(disabled)
    }

    private func axis(minValue: CGFloat? = nil, maxValue: CGFloat? = nil) -> AxisPositionCalculations<CGFloat> {
        BoundedSliderPositioning(
            axis: axis,
            absoluteMin: axis.minValue,
            absoluteMax: axis.maxValue,
            minPreSpacing: minValue,
            maxPreSpacing: maxValue,
            spacing: settings.handleThickness + 5
        ).boundedAxis
    }

    private var value2UnsafeBinding: Binding<CGFloat> {
        Binding(get: { value2! }, set: { value2 = $0 })
    }
}
