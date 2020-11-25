//
// Reactions App
//


import SwiftUI

struct EnergyBeakerWithStand: View {

    let selectedCatalyst: Catalyst?
    let selectCatalyst: (Catalyst) -> Void
    @Binding var temp: CGFloat?
    let updateConcentrationC: (CGFloat) -> Void
    let allowReactionsToC: Bool

    @State private var flameScale: CGFloat = 0
    private let tripleFlameThreshold: CGFloat = 500

    @State private var catalystInProgress: Catalyst? = nil

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                makeView(settings: EnergyBeakerSettings(geometry: geometry))
            }
        }.onAppear(perform: runFlameFlickerAnimation)
    }

    private func runFlameFlickerAnimation() {
        let animation = Animation.spring(
            response: 1
        ).repeatForever(autoreverses: true)
        withAnimation(animation) {
            self.flameScale = 0.1
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
                extraSpeed: extraSpeed(settings: settings),
                updateConcentrationC: updateConcentrationC,
                allowReactionsToC: allowReactionsToC
            )
            .frame(width: settings.beakerWidth, height: settings.beakerHeight)
            beakerStand(settings: settings)
            slider(settings: settings, temp: tempBinding)
                .padding(.top, settings.sliderTopPadding)
        }
    }

    private func catImage(
        catalyst: Catalyst,
        settings: EnergyBeakerSettings
    ) -> some View {
        let isSelected = selectedCatalyst == catalyst
        let isInProgress = catalystInProgress == catalyst
        let scale: CGFloat = isInProgress ? 1.5 : 1
        let rotation: Angle = isInProgress ? .degrees(135) : .zero
        return Image(catalystInProgress == nil || isInProgress ? catalyst.imageName : "catdeact")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: settings.catHeight)
            .scaleEffect(x: scale, y: scale, anchor: .top)
            .rotationEffect(rotation, anchor: .bottomLeading)
            .animation(.easeOut(duration: 0.75))
            .opacity(isSelected ? 0 : 1)
            .onTapGesture {
                if (catalystInProgress == nil) {
                    catalystInProgress = catalyst
                } else if selectedCatalyst == nil {
                    selectCatalyst(catalyst)
                }
            }
    }

    private func beakerStand(settings: EnergyBeakerSettings) -> some View {
        ZStack(alignment: .bottom) {
            Image("stand")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: settings.standWidth)

            flame(settings: settings)
        }
    }

    private func flame(settings: EnergyBeakerSettings) -> some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                Group {
                    smallFlame(settings: settings)
                        .offset(x: settings.flameWidth)

                    smallFlame(settings: settings)
                        .offset(x: -settings.flameWidth)
                }

                flameImage
                    .frame(width: largeFrameWidth(settings: settings))
                    .scaleEffect(
                        x: 1 + flameScale,
                        y: 1 - flameScale,
                        anchor: .bottom
                    )
            }

            Image("burner")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: settings.burnerWidth)
        }
    }

    private var flameImage: some View {
        Image("flame")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }

    private func smallFlame(settings: EnergyBeakerSettings) -> some View {
        flameImage
            .opacity((temp ?? 0) > tripleFlameThreshold ? 1 : 0)
            .animation(.easeIn(duration: 0.25))
            .frame(width: largeFrameWidth(settings: settings) * 0.6)
            .scaleEffect(
                x: 1 + flameScale,
                y: 1 - flameScale,
                anchor: .bottom
            )
    }

    private func largeFrameWidth(settings: EnergyBeakerSettings) -> CGFloat {
        let speed = extraSpeed(settings: settings)
        let maxExtraScale: CGFloat = 0.5
        let scale = 1 + (speed * maxExtraScale)
        return settings.flameWidth * scale
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

    var beakerWidth: CGFloat {
        let maxHeight = 0.5 * geometry.size.height
        let maxWidth = maxHeight / BeakerSettings.heightToWidth
        return min(maxWidth, geometry.size.width)
    }

    var beakerHeight: CGFloat {
        BeakerSettings.heightToWidth * beakerWidth
    }

    var standWidth: CGFloat {
        beakerWidth
    }

    var burnerWidth: CGFloat {
        standWidth * 0.4
    }

    var flameWidth: CGFloat {
        burnerWidth * 0.18
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
            temp: .constant(500),
            updateConcentrationC: {_ in },
            allowReactionsToC: true
        )
    }
}
