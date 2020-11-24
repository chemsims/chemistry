//
// Reactions App
//
  

import SwiftUI

struct EnergyBeakerWithStand: View {

    @State private var temp: CGFloat = 400

    var body: some View {
        GeometryReader { geometry in
            makeView(settings: EnergyBeakerSettings(geometry: geometry))
        }
    }

    private func makeView(settings: EnergyBeakerSettings) -> some View {
        VStack(spacing: 0) {
            EnergyBeaker(
                extraSpeed: ((temp - settings.axis.minValue) / (settings.axis.maxValue - settings.axis.minValue))
            ).frame(height: settings.beakerHeight)
            beakerStand
            slider(settings: settings)
                .padding(.top, settings.sliderTopPadding)
        }
    }

    private var beakerStand: some View {
        Image("stand")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }

    private func slider(settings: EnergyBeakerSettings) -> some View {
        CustomSlider(
            value: $temp,
            axis: settings.axis,
            handleThickness: settings.handleThickness,
            handleColor: .orangeAccent,
            handleCornerRadius: settings.handleCornerRadius,
            barThickness: settings.barThickness,
            barColor: Styling.timeAxisCompleteBar,
            orientation: .landscape,
            includeFill: true
        ).frame(height: settings.handleHeight)
    }
}

fileprivate struct EnergyBeakerSettings {
    let geometry: GeometryProxy

    var axis: AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: geometry.size.width * 0.1,
            maxValuePosition: geometry.size.width * 0.9,
            minValue: 400,
            maxValue: 600
        )
    }

    var beakerHeight: CGFloat {
        BeakerSettings.heightToWidth * geometry.size.width
    }

    var handleThickness: CGFloat {
        0.05 * geometry.size.width
    }

    var handleCornerRadius: CGFloat {
        0.3 * handleThickness
    }

    var barThickness: CGFloat {
        0.2 * handleThickness
    }

    var handleHeight: CGFloat {
        2 * handleThickness
    }

    var sliderTopPadding: CGFloat {
        0.2 * handleHeight
    }

}

struct EnergyBeakerWithStand_Previews: PreviewProvider {
    static var previews: some View {
        EnergyBeakerWithStand()
    }
}
