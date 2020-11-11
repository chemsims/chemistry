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

                RoundedRectangle(cornerRadius: handleCornerRadius)
                    .foregroundColor(handleColor)
                    .frame(height: handleThickness)
                    .position(x: centerXPosition(geometry), y: yPosition(totalHeight: geometry.size.height))
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let height = geometry.size.height
                                let distanceFromBottom = height - trailingPadding - gesture.location.y
                                let percentageFromBottom = distanceFromBottom / (maxY(totalHeight: height) - minY)
                                var newValue = (Value(percentageFromBottom) * (maxValue - minValue)) + minValue
                                if (newValue > maxValue) {
                                    newValue = maxValue
                                } else if (newValue < minValue) {
                                    newValue = minValue
                                }
                                self.value = newValue
                            }
                    )
            }.frame(width: geometry.size.width)
        }
    }

    /// Return the x position of the center of the slider handle
    private func centerXPosition(_ geometry: GeometryProxy) -> CGFloat {
        geometry.size.width / 2
    }

    /// Return the y position of the center of the slider handle
    private func yPosition(totalHeight height: CGFloat) -> CGFloat {
        let deltaValue = ($value.wrappedValue - minValue) / (maxValue - minValue)
        let yBottom = maxY(totalHeight: height)
        let distanceFromBottom = CGFloat(deltaValue) * (yBottom - minY)
        return yBottom - distanceFromBottom
    }

    private var minY: CGFloat {
        (handleThickness / 2) + leadingPadding
    }

    private func maxY(totalHeight height: CGFloat) -> CGFloat {
        height - trailingPadding - (handleThickness / 2)
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
