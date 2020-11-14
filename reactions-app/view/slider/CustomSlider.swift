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

    let previousHandleValue: Value?
    let previousHandlePadding: CGFloat
    let previousValueBoundType: BoundType

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                Rectangle()
                    .foregroundColor(barColor)
                    .frame(width: barWidth(geometry), height: barHeight(geometry))
                handle(
                    geometry,
                    calculations: getCalculations
                )
            }
        }
    }

    private func handle(_ geometry: GeometryProxy, calculations: AxisPositionCalculations<Value>) -> some View {
        RoundedRectangle(cornerRadius: handleCornerRadius)
            .foregroundColor(handleColor)
            .frame(width: handleWidth(geometry), height: handleHeight(geometry))
            .position(
                x: handleXPosition(geometry, calculations: calculations),
                y: handleYPosition(geometry, calculations: calculations)
            )
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        let inputValue = orientation == .portrait ? gesture.location.y : gesture.location.x
                        var newValue = calculations.getValue(at: Value(inputValue))
                        if (newValue > calculations.maxValue) {
                            newValue = calculations.maxValue
                        } else if (newValue < calculations.minValue) {
                            newValue = calculations.minValue
                        }
                        self.value = newValue
                    }
            )
    }

    private var getCalculations: AxisPositionCalculations<Value> {
        let minValuePos = axis.minValuePosition
        let maxValuePos = axis.maxValuePosition

        if let previousValue = previousHandleValue {
            let position = axis.getPosition(at: previousValue)
            let isUpperBound = previousValueBoundType == .upper

            let positionDelta = Value(handleThickness + previousHandlePadding)
            let boundsDirection = isUpperBound ? -1 : 1
            let axisDirection = (maxValuePos - minValuePos < 0) ? -1 : 1
            let positionDirection = boundsDirection * axisDirection

            let updatedPosition = position + (positionDelta * Value(positionDirection))
            let updatedValue = axis.getValue(at: updatedPosition)

            if (isUpperBound) {
                return AxisPositionCalculations(
                    minValuePosition: minValuePos,
                    maxValuePosition: updatedPosition,
                    minValue: axis.minValue,
                    maxValue: updatedValue
                )
            }
            return AxisPositionCalculations(
                minValuePosition: updatedPosition,
                maxValuePosition: maxValuePos,
                minValue: updatedValue,
                maxValue: axis.maxValue
            )
        }
        return axis
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
                        maxValuePosition: 80,
                        minValue: 1,
                        maxValue: 2
                    ),
                    handleThickness: 40,
                    handleColor: Color.orangeAccent,
                    handleCornerRadius: 15,
                    barThickness: 5,
                    barColor: Color.darkGray,
                    orientation: .landscape,
                    previousHandleValue: 1.5,
                    previousHandlePadding: 10,
                    previousValueBoundType: .lower
                ).frame(height: 80)
            }
        }
    }
}
