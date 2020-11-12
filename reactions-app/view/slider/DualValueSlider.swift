//
// Reactions App
//
  

import SwiftUI

struct DualValueSlider<Value: BinaryFloatingPoint>: View {

    @Binding var value1: Value
    @Binding var value2: Value?

    let minValue: Value
    let maxValue: Value

    let handleThickness: CGFloat
    let handleColor: Color
    let disabledHandleColor: Color
    let handleCornerRadius: CGFloat

    let barThickness: CGFloat
    let barColor: Color

    let minValuePadding: CGFloat
    let maxValuePadding: CGFloat

    let orientation: Orientation

    let boundType: BoundType

    var body: some View {
        ZStack {
            makeSlider(
                value: $value1,
                handleColor: value2Enabled ? disabledHandleColor : handleColor,
                barThickness: barThickness,
                previousHandleValue: nil
            ).disabled(value2Enabled)

            if (value2Enabled) {
                makeSlider(
                    value: value2UnsafeBinding,
                    handleColor: handleColor,
                    barThickness: 0,
                    previousHandleValue: value1
                )
            }
        }
    }

    private var value2Enabled: Bool {
        value2 != nil
    }

    private var value2UnsafeBinding: Binding<Value> {
        Binding(get: { value2! }, set: { value2 = $0 })
    }

    private func makeSlider(
        value: Binding<Value>,
        handleColor: Color,
        barThickness: CGFloat,
        previousHandleValue: Value?
    ) -> some View {
        CustomSlider(
            value: value,
            minValue: minValue,
            maxValue: maxValue,
            handleThickness: handleThickness,
            handleColor: handleColor,
            handleCornerRadius: handleCornerRadius,
            barThickness: barThickness,
            barColor: barColor,
            minValuePadding: minValuePadding,
            maxValuePadding: maxValuePadding,
            orientation: orientation,
            previousHandleValue: previousHandleValue,
            previousHandlePadding: 3,
            previousValueBoundType: boundType
        )
    }
}

struct DualValueSlider_Previews: PreviewProvider {
    static var previews: some View {
        StateWrapper()
    }

    struct StateWrapper: View {
        @State var value1 = 1.1
        @State var value2: Double? = 0.4

        var body: some View {
            VStack {
                DualValueSlider(
                    value1: $value1,
                    value2: $value2,
                    minValue: 0,
                    maxValue: 2,
                    handleThickness: 40,
                    handleColor: Color.orangeAccent,
                    disabledHandleColor: Color.gray,
                    handleCornerRadius: 15,
                    barThickness: 5,
                    barColor: Color.darkGray,
                    minValuePadding: 50,
                    maxValuePadding: 50,
                    orientation: .landscape,
                    boundType: .lower
                ).frame(height: 80)

                Button(action: {
                    if (value2 == nil) {
                        value2 = Double.random(in: 0...1)
                    } else {
                        value2 = nil
                    }
                }) {
                    Text("Click")
                }
            }
        }

    }
}
