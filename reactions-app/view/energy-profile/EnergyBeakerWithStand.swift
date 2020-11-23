//
// Reactions App
//
  

import SwiftUI

struct EnergyBeakerWithStand: View {

    @State private var temp: CGFloat = 400

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                EnergyBeaker(
                    extraSpeed: ((temp - 400) / 200)
                )
                    .frame(height: geometry.size.height / 1.5)
                beakerStand(geometry: geometry)
                slider(geometry: geometry)
            }
        }
    }

    private func beakerStand(geometry: GeometryProxy) -> some View {
        Image("stand")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }

    private func slider(geometry: GeometryProxy) -> some View {
        CustomSlider(
            value: $temp,
            axis: AxisPositionCalculations(
                minValuePosition: 20,
                maxValuePosition: geometry.size.width - 20,
                minValue: 400,
                maxValue: 600
            ),
            handleThickness: 20,
            handleColor: .orangeAccent,
            handleCornerRadius: 10,
            barThickness: 5,
            barColor: Styling.timeAxisCompleteBar,
            orientation: .landscape,
            includeFill: true
        ).frame(height: 40)

    }
}

struct EnergyBeakerWithStand_Previews: PreviewProvider {
    static var previews: some View {
        EnergyBeakerWithStand()
    }
}
