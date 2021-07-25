//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct DualValueSlider: View {

    @Binding var value1: CGFloat
    @Binding var value2: CGFloat?

    let value1Limits: InputLimits
    let value2Limits: InputLimits

    let value1Label: String
    let value2Label: String

    let axis: AxisPositionCalculations<CGFloat>
    let orientation: Orientation
    let settings: ReactionRateChartLayoutSettings
    let canSetInitialValue: Bool

    let disabled: Bool
    let value1Disabled: Bool
    let value1IsLower: Bool

    var body: some View {
        ZStack {
            if canSetInitialValue {
                slider(
                    binding: $value1,
                    axis: axis(limits: value1Limits),
                    disabled: value1Disabled,
                    showBar: true
                )
                .accessibility(label: Text(value1Label))
                .accessibility(hidden: value2 != nil)
            }

            if value2 != nil {
                slider(
                    binding: value2UnsafeBinding,
                    axis: axis(limits: value2Limits),
                    disabled: false,
                    showBar: canSetInitialValue ? false : true
                )
                .accessibility(label: Text(value2Label))
            }
        }
        .modifier(
            DisabledSliderModifier(disabled: disabled)
        )
    }

    private func slider(
        binding: Binding<CGFloat>,
        axis: AxisPositionCalculations<CGFloat>,
        disabled: Bool,
        showBar: Bool
    ) -> some View {
        let baseSettings = settings.sliderSettings
        let adjustedSettings = showBar ? baseSettings : baseSettings.updating(barThickness: 0)

        // Pass in disabled: false as we handle disabled styling for both sliders
        // combined
        return CustomSlider(
            value: binding,
            axis: axis,
            orientation: orientation,
            includeFill: false,
            settings: adjustedSettings,
            disabled: false,
            handleColor: disabled ? Color.gray : Color.orangeAccent,
            barColor: Color.black,
            useHaptics: true
        )
        .disabled(disabled)
    }

    private func axis(limits: InputLimits) -> AxisPositionCalculations<CGFloat> {
        LimitConstraints.constrain(
            limit: limits,
            axis: axis,
            spacing: settings.inputSpacing
        )
    }

    private var value2UnsafeBinding: Binding<CGFloat> {
        Binding(get: { value2! }, set: { value2 = $0 })
    }
}
