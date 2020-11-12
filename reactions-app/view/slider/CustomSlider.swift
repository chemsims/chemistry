//
// Reactions App
//
  

import SwiftUI

struct CustomSlider<Value>: View where Value: BinaryFloatingPoint {

    @Binding var value: Value
    let minValue: Value
    let maxValue: Value

    let handleThickness: CGFloat
    let handleColor: Color
    let handleCornerRadius: CGFloat

    let barThickness: CGFloat
    let barColor: Color

    let minValuePadding: CGFloat
    let maxValuePadding: CGFloat

    let orientation: Orientation

    let previousHandleValue: Value?
    let previousHandlePadding: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                Rectangle()
                    .foregroundColor(barColor)
                    .frame(width: barWidth(geometry), height: barHeight(geometry))
                handle(
                    geometry,
                    calculations: getCalculations(geometry: geometry)
                )
            }
        }
    }

    private func handle(_ geometry: GeometryProxy, calculations: SliderCalculations<Value>) -> some View {
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
                        var newValue = calculations.getValue(forHandle: Value(inputValue))
                        if (newValue > calculations.maxValue) {
                            newValue = calculations.maxValue
                        } else if (newValue < minValue) {
                            newValue = minValue
                        }
                        self.value = newValue
                    }
            )
    }

    private func getCalculations(geometry: GeometryProxy) -> SliderCalculations<Value> {
        let length = isPortrait ? geometry.size.height : geometry.size.width
        let minValuePos = isPortrait ? Value(length - minValuePadding) : Value(minValuePadding)
        let maxValuePos = isPortrait ? Value(maxValuePadding) : Value(length - maxValuePadding)
        let calculations = SliderCalculations(
            minValuePosition: minValuePos,
            maxValuePosition: maxValuePos,
            minValue: minValue,
            maxValue: maxValue
        )
        if let previousValue = previousHandleValue {
            let position = calculations.getHandleCenter(at: previousValue)
            let newMaxValuePos = position - Value(handleThickness + previousHandlePadding)
            let newMaxValue = calculations.getValue(forHandle: newMaxValuePos)
            return SliderCalculations(
                minValuePosition: minValuePos,
                maxValuePosition: newMaxValuePos,
                minValue: minValue,
                maxValue: newMaxValue
            )
        }
        return calculations
    }

    /// Return the x position of the center of the slider handle
    private func handleXPosition(_ geometry: GeometryProxy, calculations: SliderCalculations<Value>) -> CGFloat {
        if (isPortrait) {
            return geometry.size.width / 2
        }
        return CGFloat(calculations.getHandleCenter(at: value))
    }

    /// Return the y position of the center of the slider handle
    private func handleYPosition(_ geometry: GeometryProxy, calculations: SliderCalculations<Value>) -> CGFloat {
        if (isPortrait) {
            return CGFloat(calculations.getHandleCenter(at: value))
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
                    minValue: 1,
                    maxValue: 2,
                    handleThickness: 40,
                    handleColor: Color.orangeAccent,
                    handleCornerRadius: 15,
                    barThickness: 5,
                    barColor: Color.darkGray,
                    minValuePadding: 50,
                    maxValuePadding: 50,
                    orientation: .landscape,
                    previousHandleValue: nil,
                    previousHandlePadding: 10
                ).frame(height: 80)
            }
        }
    }
}
