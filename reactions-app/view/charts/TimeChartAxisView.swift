//
// Reactions App
//
  

import SwiftUI

struct TimeChartAxisView<Value>: View where Value: BinaryFloatingPoint {

    @Binding var concentration: Value
    @Binding var time: Value

    var body: some View {
        HStack {
            VStack {
                Text("[A]")
                Text("\(Double(concentration), specifier: "%.2f") M").foregroundColor(.orangeAccent)
            }.frame(minWidth: 80)

            HStack(alignment: .top) {
                slider(isPortrait: true)
                VStack {
                    TimeChartAxisShape(verticalTicks: 10, horizontalTicks: 10, tickSize: 10, gapToTop: 60, gapToSide: 60)
                        .stroke()
                        .frame(width: 250, height: 250)
                        .overlay(verticalIndicator, alignment: .leading)
                        .overlay(horizontalIndicator, alignment: .bottom)

                    slider(isPortrait: false)

                    Text("Time ") + Text("\(Double(time), specifier: "%.1f") s").foregroundColor(.orangeAccent)
                }
            }
        }
    }

    private var verticalIndicator: some View {
        indicator(isPortrait: true)
    }

    private var horizontalIndicator: some View {
        indicator(isPortrait: false)
    }

    private func slider(isPortrait: Bool) -> some View {
        let width: CGFloat = isPortrait ? 40 : 250
        let height: CGFloat = isPortrait ? 250 : 40
        return CustomSlider(
            value: isPortrait ? $concentration : $time,
            minValue: 0,
            maxValue: 1,
            handleThickness: 20,
            handleColor: Color.orangeAccent,
            handleCornerRadius: 5,
            barThickness: 3,
            barColor: Color.darkGray,
            leadingPadding: 10,
            trailingPadding: 10,
            orientation: isPortrait ? .portrait : .landscape
        ).frame(width: width, height: height)
    }

    private func indicator(isPortrait: Bool) -> some View {
        let width: CGFloat = isPortrait ? 25 : 250
        let height: CGFloat = isPortrait ? 250 : 25
        return CustomSlider(
            value: isPortrait ? $concentration : $time,
            minValue: 0,
            maxValue: 1,
            handleThickness: 2,
            handleColor: Color.orangeAccent,
            handleCornerRadius: 0,
            barThickness: 0,
            barColor: Color.darkGray,
            leadingPadding: 10,
            trailingPadding: 10,
            orientation: isPortrait ? .portrait : .landscape
        ).frame(width: width, height: height).disabled(true)
    }

}

struct TimeChartAxisView_Previews: PreviewProvider {
    static var previews: some View {
        TimeChartAxisView(
            concentration: .constant(0.5),
            time: .constant(0.5)
        )
    }
}
