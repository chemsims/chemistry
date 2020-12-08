//
// Reactions App
//
  

import SwiftUI

struct CustomSlider<Value>: View where Value: BinaryFloatingPoint {

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


    init(
        value: Binding<Value>,
        axis: AxisPositionCalculations<Value>,
        handleThickness: CGFloat,
        handleColor: Color,
        handleCornerRadius: CGFloat,
        barThickness: CGFloat,
        barColor: Color,
        orientation: Orientation,
        includeFill: Bool,
        useHaptics: Bool = true
    ) {
        self._value = value
        self.axis = axis
        self.handleThickness = handleThickness
        self.handleColor = handleColor
        self.handleCornerRadius = handleCornerRadius
        self.barThickness = barThickness
        self.barColor = barColor
        self.orientation = orientation
        self.includeFill = includeFill
        self.useHaptics = useHaptics
    }

    @State private var impactGenerator = UIImpactFeedbackGenerator(style: .light)
    @State private var didPrepareImpact = false

    @State private var scaleFactor: CGFloat = 0
    @State private var scaleAnchor: UnitPoint = .center

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                Rectangle()
                    .foregroundColor(barColor)
                    .frame(width: barWidth(geometry), height: barHeight(geometry))

                if (includeFill) {
                    Rectangle()
                        .foregroundColor(handleColor)
                        .frame(
                            width: handleXPosition(geometry, calculations: axis),
                            height: barHeight(geometry),
                            alignment: .leading
                        ).position(
                            x: handleXPosition(geometry, calculations: axis) / 2,
                            y: geometry.size.height / 2
                        )
                }

                handle(
                    geometry: geometry,
                    axis: axis
                )
            }
        }
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
                        var newValue = axis.getValue(at: Value(inputValue))
                        setHandleScale(
                            geometry: geometry,
                            value: newValue,
                            location: inputValue
                        )
                        if (newValue > axis.maxValue) {
                            newValue = axis.maxValue
                        } else if (newValue < axis.minValue) {
                            newValue = axis.minValue
                        }
                        if (useHaptics) {
                            handleHaptics(newValue: newValue, oldValue: self.value)
                        }

                        self.value = newValue
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


    /// Sets the handle scale when `value` exceeds the axis limits.
    /// The scale is calculated using the formula a(1 - e^(bx)), where
    /// a is the maximum allowed scale. The coefficient of b is calculated
    /// based on the value of x which produces 0.8.
    private func setHandleScale(
        geometry: GeometryProxy,
        value: Value,
        location: CGFloat
    ) {
        if (value > axis.maxValue || value < axis.minValue) {
            let axisLength = isPortrait ? geometry.size.height : geometry.size.width
            let bounds = value > axis.maxValue ? axis.maxValuePosition : axis.minValuePosition
            let delta = abs(location - CGFloat(bounds))

            // The distance to 0.8 of the maxScale
            let deltaTo80: CGFloat = axisLength
            let maxScale: CGFloat = 0.08
            let deltaFactor = 1.6 / deltaTo80
            let scale = maxScale - (maxScale * pow(CGFloat(Darwin.M_E), -deltaFactor * delta))

            self.scaleFactor = scale
            if (value > axis.maxValue) {
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
        if (newValue > oldValue) {
            if (newValue >= axis.maxValue) {
                impactGenerator.impactOccurred()
            }
            else if (newValue >= 0.75 * axis.maxValue) {
                impactGenerator.prepare()
            }
        } else if (newValue < oldValue) {
            if (newValue <= axis.minValue) {
                impactGenerator.impactOccurred()
            } else if (newValue <= 1.25 * axis.minValue) {
                impactGenerator.prepare()
            }
        }
    }

    /// Return the x position of the center of the slider handle
    private func handleXPosition(_ geometry: GeometryProxy, calculations: AxisPositionCalculations<Value>) -> CGFloat {
        if (isPortrait) {
            return geometry.size.width / 2
        }
        return CGFloat(calculations.getPosition(at: value))
    }

    /// Return the y position of the center of the slider handle
    private func handleYPosition(_ geometry: GeometryProxy, calculations: AxisPositionCalculations<Value>) -> CGFloat {
        if (isPortrait) {
            return CGFloat(calculations.getPosition(at: value))
        }
        return geometry.size.height / 2
    }

    private func barHeight(_ geometry: GeometryProxy) -> CGFloat {
        if (isPortrait) {
            return geometry.size.height
        }
        return barThickness
    }

    private func barWidth(_ geometry: GeometryProxy) -> CGFloat {
        if (isPortrait) {
            return barThickness
        }
        return geometry.size.width
    }

    private func handleWidth(_ geometry: GeometryProxy) -> CGFloat {
        if (isPortrait) {
            return geometry.size.width
        }
        return handleThickness
    }

    private func handleHeight(_ geometry: GeometryProxy) -> CGFloat {
        if (isPortrait) {
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

    struct ViewWrapper: View  {
        @State var value: CGFloat = 1.5

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
                    handleThickness: 40,
                    handleColor: Color.orangeAccent,
                    handleCornerRadius: 15,
                    barThickness: 5,
                    barColor: Color.darkGray,
                    orientation: .landscape,
                    includeFill: true
                ).frame(height: 80)
            }
        }
    }
}
