//
// Reactions App
//
  

import SwiftUI

struct EnergyBeakerWithStand: View {

    let selectedCatalyst: Catalyst?
    let selectCatalyst: (Catalyst) -> Void
    @Binding var temp: CGFloat?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                makeView(settings: EnergyBeakerSettings(geometry: geometry))
            }

        }
    }

    private func makeView(settings: EnergyBeakerSettings) -> some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                catImage(catalyst: .A, settings: settings)
                Spacer()
                catImage(catalyst: .B, settings: settings)
                Spacer()
                catImage(catalyst: .C, settings: settings)
                Spacer()
            }
            Spacer()
            EnergyBeaker(
                extraSpeed: extraSpeed(settings: settings)
            )
            .frame(height: settings.beakerHeight)
            beakerStand(settings: settings)
            slider(settings: settings, temp: tempBinding)
                .padding(.top, settings.sliderTopPadding)
        }
    }

    private func catImage(
        catalyst: Catalyst,
        settings: EnergyBeakerSettings
    ) -> some View {
        Image(selectedCatalyst == nil ? catalyst.imageName : "catdeact")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: settings.catHeight)
            .onTapGesture {
                if selectedCatalyst == nil {
                    selectCatalyst(catalyst)
                }
            }
    }

    private func beakerStand(settings: EnergyBeakerSettings) -> some View {
        Image("stand")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: settings.geometry.size.width)
    }

    private func slider(
        settings: EnergyBeakerSettings,
        temp: Binding<CGFloat>?
    ) -> some View {
        CustomSlider(
            value: temp ?? .constant(settings.axis.minValue),
            axis: settings.axis,
            handleThickness: settings.handleThickness,
            handleColor:tempBinding == nil ? .darkGray : .orangeAccent,
            handleCornerRadius: settings.handleCornerRadius,
            barThickness: settings.barThickness,
            barColor: Styling.timeAxisCompleteBar,
            orientation: .landscape,
            includeFill: true
        )
        .frame(height: settings.handleHeight)
        .disabled(tempBinding == nil)
    }

    private var tempBinding: Binding<CGFloat>? {
        if temp != nil {
            return Binding(get: { temp! }, set: { temp = $0 })
        }
        return nil
    }

    private func extraSpeed(settings: EnergyBeakerSettings) -> CGFloat {
        if let temp = temp {
            let numerator = temp - settings.axis.minValue
            let delta = settings.axis.maxValue - settings.axis.minValue
            return numerator / delta
        }
        return 0
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

    var catHeight: CGFloat {
        0.13 * geometry.size.height
    }

}


extension Catalyst {
    var imageName: String {
        switch(self) {
        case .A: return "catone"
        case .B: return "cattwo"
        case .C: return "catthree"
        }
    }
}

struct EnergyBeakerWithStand_Previews: PreviewProvider {
    static var previews: some View {
        EnergyBeakerWithStand(
            selectedCatalyst: nil,
            selectCatalyst: {_ in },
            temp: .constant(500)
        )
    }
}
