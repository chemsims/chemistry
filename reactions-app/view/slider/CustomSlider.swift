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
                        ).position(x: handleXPosition(geometry, calculations: axis) / 2, y: geometry.size.height / 2)
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
            .position(
                x: handleXPosition(geometry, calculations: axis),
                y: handleYPosition(geometry, calculations: axis)
            )
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        let inputValue = orientation == .portrait ? gesture.location.y : gesture.location.x
                        var newValue = axis.getValue(at: Value(inputValue))
                        if (newValue > axis.maxValue) {
                            newValue = axis.maxValue
                        } else if (newValue < axis.minValue) {
                            newValue = axis.minValue
                        }
                        self.value = newValue
                    }
            )
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
