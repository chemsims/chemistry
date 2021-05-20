//
// Reactions App
//

import SwiftUI

public struct CustomSlider<Value>: View where Value: BinaryFloatingPoint {

    @Binding var value: Value
    let axis: AxisPositionCalculations<Value>

    let handleThickness: CGFloat
    let handleColor: Color
    let handleCornerRadius: CGFloat

    let barThickness: CGFloat
    let barColor: Color

    let orientation: Orientation

    let includeFill: Bool
    let useHaptics: Bool
    let disabled: Bool

    let formatAccessibilityValue: (Value) -> String

    public init(
        value: Binding<Value>,
        axis: AxisPositionCalculations<Value>,
        orientation: Orientation,
        includeFill: Bool,
        settings: SliderGeometrySettings,
        disabled: Bool,
        useHaptics: Bool,
        formatAccessibilityValue: @escaping (Value) -> String = { $0.str(decimals: 2) }
    ) {
        self.init(
            value: value,
            axis: axis,
            orientation: orientation,
            includeFill: includeFill,
            settings: settings,
            disabled: disabled,
            handleColor: disabled ? .darkGray : .orangeAccent,
            barColor: Styling.energySliderBar,
            useHaptics: useHaptics,
            formatAccessibilityValue: formatAccessibilityValue
        )
    }

    public init(
        value: Binding<Value>,
        axis: AxisPositionCalculations<Value>,
        orientation: Orientation,
        includeFill: Bool,
        settings: SliderGeometrySettings,
        disabled: Bool,
        handleColor: Color,
        barColor: Color,
        useHaptics: Bool,
        formatAccessibilityValue: @escaping (Value) -> String = { $0.str(decimals: 2) }
    ) {
        self._value = value
        self.axis = axis
        self.handleThickness = settings.handleThickness
        self.handleColor = handleColor
        self.handleCornerRadius = settings.handleCornerRadius
        self.barThickness = settings.barThickness
        self.barColor = barColor
        self.orientation = orientation
        self.includeFill = includeFill
        self.useHaptics = useHaptics
        self.disabled = disabled
        self.hapticHandler = SliderHapticsHandler(
            axis: axis,
            impactGenerator: UIImpactFeedbackGenerator(style: .light)
        )
        self.formatAccessibilityValue = formatAccessibilityValue
    }

    private let hapticHandler: SliderHapticsHandler<Value>
    @State private var scaleFactor: CGFloat = 0
    @State private var scaleAnchor: UnitPoint = .center

    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                Rectangle()
                    .foregroundColor(barColor)
                    .frame(width: barWidth(geometry), height: barHeight(geometry))

                if includeFill {
                   fill(geometry: geometry)
                }

                handle(
                    geometry: geometry,
                    axis: axis
                )
            }
            .accessibility(value: Text(formatAccessibilityValue(value)))
            .accessibilityAdjustableAction { direction in
                if direction == .increment {
                    setNewValue(newValue: value + axis.accessibilityIncrement)
                } else if direction == .decrement {
                    setNewValue(newValue: value - axis.accessibilityIncrement)
                }
            }
        }.modifier(
            DisabledSliderModifier(disabled: disabled)
        )
    }

    private func handle(geometry: GeometryProxy, axis: AxisPositionCalculations<Value>) -> some View {
        RoundedRectangle(cornerRadius: handleCornerRadius)
            .foregroundColor(handleColor)
            .frame(width: handleWidth(geometry), height: handleHeight(geometry))
            .scaleEffect(
                x: isPortrait ? 1 + scaleFactor : 1 - scaleFactor,
                y: isPortrait ? 1 - scaleFactor : 1 + scaleFactor,
                anchor: scaleAnchor
            )
            .position(
                x: handleXPosition(geometry, calculations: axis),
                y: handleYPosition(geometry, calculations: axis)
            )
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let inputValue = orientation == .portrait ? gesture.location.y : gesture.location.x
                        let newValue = axis.getValue(at: Value(inputValue))
                        setHandleScale(
                            geometry: geometry,
                            value: newValue,
                            location: inputValue
                        )
                        setNewValue(newValue: newValue)
                    }.onEnded { _ in
                        let animation = Animation.spring(
                            response: 0.1,
                            dampingFraction: 0.9
                        )
                        withAnimation(animation) {
                            scaleFactor = 0
                        }
                    }
            )
    }

    private func fill(geometry: GeometryProxy) -> some View {
        let handleXPos = handleXPosition(geometry, calculations: axis)
        let handleYPos = handleYPosition(geometry, calculations: axis)

        let geoHeight = geometry.size.height

        let width = isPortrait ? barThickness : handleXPos
        let height = isPortrait ? geoHeight - handleYPos : barHeight(geometry)

        let x = isPortrait ? geometry.size.width / 2 : handleXPos / 2
        let y = isPortrait ? geoHeight - (height / 2) : geoHeight / 2
        return Rectangle()
            .foregroundColor(handleColor)
            .frame(
                width: width,
                height: height,
                alignment: .leading
            )
            .position(
                x: x,
                y: y
            )
    }

    private func setNewValue(newValue value: Value) {
        var newValue = value
        if newValue > axis.maxValue {
            newValue = axis.maxValue
        } else if newValue < axis.minValue {
            newValue = axis.minValue
        }
        if useHaptics {
            handleHaptics(newValue: newValue, oldValue: self.value)
        }

        self.value = newValue
    }

    /// Sets the handle scale when `value` exceeds the axis limits.
    /// The scale is calculated using the formula a(1 - e^(bx)), where
    /// a is the maximum allowed scale. The coefficient of b is calculated
    /// based on the value of x which produces 0.8.
    private func setHandleScale(
        geometry: GeometryProxy,
        value: Value,
        location: CGFloat
    ) {
        if value > axis.maxValue || value < axis.minValue {
            let axisLength = isPortrait ? geometry.size.height : geometry.size.width
            let bounds = value > axis.maxValue ? axis.maxValuePosition : axis.minValuePosition
            let delta = abs(location - CGFloat(bounds))

            // The distance to 0.8 of the maxScale
            let deltaTo80: CGFloat = axisLength
            let maxScale: CGFloat = 0.08
            let deltaFactor = 1.6 / deltaTo80
            let scale = maxScale - (maxScale * pow(CGFloat(Darwin.M_E), -deltaFactor * delta))

            self.scaleFactor = scale
            if value > axis.maxValue {
                self.scaleAnchor = isPortrait ? .top : .trailing
            } else {
                self.scaleAnchor = isPortrait ? .bottom : .leading
            }
        } else {
            self.scaleFactor = 0
        }
    }

    private func handleHaptics(
        newValue: Value,
        oldValue: Value
    ) {
        hapticHandler.valueDidChange(newValue: newValue, oldValue: oldValue)
    }

    /// Return the x position of the center of the slider handle
    private func handleXPosition(_ geometry: GeometryProxy, calculations: AxisPositionCalculations<Value>) -> CGFloat {
        if isPortrait {
            return geometry.size.width / 2
        }
        return CGFloat(calculations.getPosition(at: value))
    }

    /// Return the y position of the center of the slider handle
    private func handleYPosition(_ geometry: GeometryProxy, calculations: AxisPositionCalculations<Value>) -> CGFloat {
        if isPortrait {
            return CGFloat(calculations.getPosition(at: value))
        }
        return geometry.size.height / 2
    }

    private func barHeight(_ geometry: GeometryProxy) -> CGFloat {
        if isPortrait {
            return geometry.size.height
        }
        return barThickness
    }

    private func barWidth(_ geometry: GeometryProxy) -> CGFloat {
        if isPortrait {
            return barThickness
        }
        return geometry.size.width
    }

    private func handleWidth(_ geometry: GeometryProxy) -> CGFloat {
        if isPortrait {
            return geometry.size.width
        }
        return handleThickness
    }

    private func handleHeight(_ geometry: GeometryProxy) -> CGFloat {
        if isPortrait {
            return handleThickness
        }
        return geometry.size.height
    }

    private var isPortrait: Bool {
        orientation == .portrait
    }
}

struct CustomSlider_Previews: PreviewProvider {

    static var previews: some View {
        ViewWrapper()
    }

    struct ViewWrapper: View {
        @State var value: CGFloat = 1.5

        let width: CGFloat = 80

        var body: some View {
            VStack {
                Text("\(value)")

                CustomSlider(
                    value: $value,
                    axis: AxisPositionCalculations(
                        minValuePosition: 0,
                        maxValuePosition: 250,
                        minValue: 1,
                        maxValue: 2
                    ),
                    orientation: .landscape,
                    includeFill: true,
                    settings: SliderGeometrySettings(handleWidth: width),
                    disabled: false,
                    useHaptics: false
                ).frame(height: width)

                CustomSlider(
                    value: $value,
                    axis: AxisPositionCalculations(
                        minValuePosition: 250,
                        maxValuePosition: 0,
                        minValue: 1,
                        maxValue: 2
                    ),
                    orientation: .portrait,
                    includeFill: true,
                    settings: SliderGeometrySettings(handleWidth: width),
                    disabled: false,
                    useHaptics: false
                ).frame(width: width)
            }
        }
    }
}
 
