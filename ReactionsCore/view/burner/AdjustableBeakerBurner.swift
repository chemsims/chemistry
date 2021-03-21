//
// Reactions App
//


import SwiftUI

// TODO - make the accessibility value not optional
public struct AdjustableBeakerBurner: View {

    @Binding var temp: CGFloat
    let disabled: Bool
    let useHaptics: Bool
    let highlightSlider: Bool
    let showFlame: Bool
    let sliderAccessibilityValue: String?
    let settings: AdjustableBeakerBurnerSettings

    public init(
        temp: Binding<CGFloat>,
        disabled: Bool,
        useHaptics: Bool,
        highlightSlider: Bool,
        showFlame: Bool,
        sliderAccessibilityValue: String?,
        settings: AdjustableBeakerBurnerSettings
    ) {
        self._temp = temp
        self.disabled = disabled
        self.useHaptics = useHaptics
        self.highlightSlider = highlightSlider
        self.showFlame = showFlame
        self.sliderAccessibilityValue = sliderAccessibilityValue
        self.settings = settings
    }

    public var body: some View {
        VStack(spacing: 0) {
            BeakerBurner(
                temp: $temp,
                showFlame: showFlame,
                settings: settings.burnerSettings
            )

            slider
        }
    }

    private var slider: some View {
        CustomSlider(
            value: $temp,
            axis: settings.axis,
            orientation: .landscape,
            includeFill: true,
            settings: settings.sliderSettings,
            disabled: disabled,
            handleColor: disabled ? .darkGray : .orangeAccent,
            barColor: Styling.energySliderBar,
            useHaptics: useHaptics
        )
        .frame(
            height: settings.sliderSettings.handleWidth
        )
        .disabled(disabled)
        .padding(.top, settings.sliderTopPadding)
        .background(
            Color.white
                .padding(.bottom, -settings.sliderTopPadding)
                .opacity(highlightSlider ? 1 : 0)
        )
        .accessibility(label: Text("Input for temperature in Kelvin"))
        .accessibility(value: Text(sliderAccessibilityValue ?? ""))

    }
}

public struct AdjustableBeakerBurnerSettings {

    public let standWidth: CGFloat
    public let handleHeight: CGFloat
    public let axis: AxisPositionCalculations<CGFloat>

    public init(
        standWidth: CGFloat,
        handleHeight: CGFloat,
        axis: AxisPositionCalculations<CGFloat>
    ) {
        self.standWidth = standWidth
        self.handleHeight = handleHeight
        self.axis = axis
    }

    public var burnerSettings: BurnerSettings {
        BurnerSettings(
            standWidth: standWidth,
            minTemp: axis.minValue,
            maxTemp: axis.maxValue,
            tripleFlameThreshold: (axis.minValue + axis.maxValue) / 2
        )
    }

    public var sliderSettings: SliderGeometrySettings {
        SliderGeometrySettings(handleWidth: handleHeight)
    }

    public var sliderTopPadding: CGFloat {
        0.2 * handleHeight
    }

}

struct AdjustableBeakerBurner_Previews: PreviewProvider {
    static var previews: some View {
        AdjustableBeakerBurner(
            temp: .constant(100),
            disabled: true,
            useHaptics: true,
            highlightSlider: false,
            showFlame: true,
            sliderAccessibilityValue: "",
            settings: AdjustableBeakerBurnerSettings(
                standWidth: 300,
                handleHeight: 30,
                axis: AxisPositionCalculations(
                    minValuePosition: 0,
                    maxValuePosition: 200,
                    minValue: 0,
                    maxValue: 200
                )
            )
        )
    }
}
