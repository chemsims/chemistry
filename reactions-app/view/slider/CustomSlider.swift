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

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                Rectangle()
                    .foregroundColor(barColor)
                    .frame(width: barThickness)
                handle(
                    geometry,
                    calculations: getCalculations(totalHeight: geometry.size.height)
                )
            }.frame(width: geometry.size.width)
        }
    }

    private func handle(_ geometry: GeometryProxy, calculations: SliderCalculations<Value>) -> some View {
        RoundedRectangle(cornerRadius: handleCornerRadius)
            .foregroundColor(handleColor)
            .frame(height: handleThickness)
            .position(x: centerXPosition(geometry), y: yPosition(calculations: calculations))
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        var newValue = calculations.getValue(forHandle: Value(gesture.location.y))
                        if (newValue > maxValue) {
                            newValue = maxValue
                        } else if (newValue < minValue) {
                            newValue = minValue
                        }
                        self.value = newValue
                    }
            )
    }

    private func getCalculations(totalHeight height: CGFloat) -> SliderCalculations<Value> {
        SliderCalculations(
            minValuePosition: Value(height - trailingPadding),
            maxValuePosition: Value(leadingPadding),
            minValue: minValue,
            maxValue: maxValue
        )
    }

    /// Return the x position of the center of the slider handle
    private func centerXPosition(_ geometry: GeometryProxy) -> CGFloat {
        geometry.size.width / 2
    }

    /// Return the y position of the center of the slider handle
    private func yPosition(calculations: SliderCalculations<Value>) -> CGFloat {
        CGFloat(calculations.getHandleCenter(at: value))
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
                handleThickness: 50,
                handleColor: Color.orangeAccent,
                handleCornerRadius: 15,
                barThickness: 5,
                barColor: Color.darkGray,
                leadingPadding: 50,
                trailingPadding: 50
            ).frame(width: 100)
        }

    }
}

class CustomSliderPreview: ObservableObject {
    @Published var value: CGFloat = 1
}
