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

    let leadingPadding: CGFloat
    let trailingPadding: CGFloat

    let orientation: Orientation

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
            }.frame(width: geometry.size.width)
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
                        if (newValue > maxValue) {
                            newValue = maxValue
                        } else if (newValue < minValue) {
                            newValue = minValue
                        }
                        self.value = newValue
                    }
            )
    }

    private func getCalculations(geometry: GeometryProxy) -> SliderCalculations<Value> {
        let length = isPortrait ? geometry.size.height : geometry.size.width
        let minValuePos = isPortrait ? Value(length - trailingPadding) : Value(leadingPadding)
        let maxValuePos = isPortrait ? Value(leadingPadding) : Value(length - trailingPadding)
        return SliderCalculations(
            minValuePosition: minValuePos,
            maxValuePosition: maxValuePos,
            minValue: minValue,
            maxValue: maxValue
        )
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
            return barThickness
        }
        return geometry.size.height
    }

    private var isPortrait: Bool {
        orientation == .portrait
    }
}

struct CustomSlider_Previews: PreviewProvider {
    @ObservedObject static var value = CustomSliderPreview()

    static var previews: some View {
        VStack {
            Text("\(value.value)")

            CustomSlider(
                value: $value.value,
                minValue: 1,
                maxValue: 2,
                handleThickness: 40,
                handleColor: Color.orangeAccent,
                handleCornerRadius: 15,
                barThickness: 5,
                barColor: Color.darkGray,
                leadingPadding: 50,
                trailingPadding: 50,
                orientation: .landscape
            ).frame(height: 80)
        }

    }
}

class CustomSliderPreview: ObservableObject {
    @Published var value: CGFloat = 1
}
