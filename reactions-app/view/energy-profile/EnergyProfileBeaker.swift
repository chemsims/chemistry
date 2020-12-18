//
// Reactions App
//


import SwiftUI

struct EnergyProfileBeaker: View {

    let catalystState: CatalystState
    let selectCatalyst: (Catalyst) -> Void
    let setCatalystInProgress: (Catalyst) -> Void

    let emitCatalyst: Bool

    @Binding var temp: CGFloat?
    let extraEnergyFactor: CGFloat
    let updateConcentrationC: (CGFloat) -> Void
    let reactionHasStarted: Bool
    let catalystIsShaking: Bool

    let canReactToC: Bool
    let canSelectCatalyst: Bool
    let reactionHasEnded: Bool
    let highlightSlider: Bool
    let highlightBeaker: Bool

    @State private var flameScale: CGFloat = 0
    private let tripleFlameThreshold: CGFloat = 500

    var body: some View {
        GeometryReader { geometry in
            makeView(settings: EnergyBeakerSettings(geometry: geometry))
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
        ZStack(alignment: .top) {
            stackView(settings: settings)

            catalystView(settings: settings)

            shakeText(settings: settings)
                .opacity(isPending ? 1 : 0)
                .animation(.easeOut(duration: 0.75))
        }
    }

    private func shakeText(settings: EnergyBeakerSettings) -> some View {
        HStack {
            Spacer()
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: settings.catHeight)
                Image(systemName: "arrowtriangle.up.fill")
                Text("shake")
                Image(systemName: "arrowtriangle.down.fill")
            }
            .font(.system(size: settings.shakeFontSize))
            .foregroundColor(.darkGray)
        }
    }

    private func stackView(settings: EnergyBeakerSettings) -> some View {
        VStack(spacing: 0) {
            beakerView(settings: settings)
                .frame(width: settings.beakerWidth, height: settings.skSceneHeight)
            beakerStand(settings: settings)
            slider(settings: settings, temp: tempBinding)
                .padding(.top, settings.sliderTopPadding)
                .background(
                    Color.white
                        .padding(.bottom, -settings.sliderTopPadding)
                        .opacity(highlightSlider ? 1 : 0)
                )
        }
    }

    private func beakerView(
        settings: EnergyBeakerSettings
    ) -> some View {
        ZStack(alignment: .bottom) {
            Color.white.mask(
                BeakerShape(
                    lipHeight: settings.beaker.lipRadius,
                    lipWidthLeft: settings.beaker.lipWidthLeft,
                    lipWidthRight: settings.beaker.lipWidthLeft,
                    leftCornerRadius: settings.beaker.outerBottomCornerRadius,
                    rightCornerRadius: settings.beaker.outerBottomCornerRadius,
                    bottomGap: 0,
                    rightGap: 0
                )
            )
            .frame(height: settings.beakerHeight)
            .opacity(highlightBeaker ? 1 : 0)

            beakerTicks(settings: settings)
            beakerFill(settings: settings)
            EmptyBeaker(settings: settings.beaker)
                .frame(width: settings.beakerWidth, height: settings.beakerHeight)

        }
    }

    private func beakerFill(settings: EnergyBeakerSettings) -> some View {
        Group {
            Rectangle()
                .frame(
                    width: settings.beaker.innerBeakerWidth,
                    height: settings.waterHeight
                )
                .foregroundColor(Styling.beakerLiquid)
            skSceneView(settings: settings)
        }.mask(
            BeakerBottomShape(cornerRadius: settings.beaker.outerBottomCornerRadius)
        ).colorMultiply(highlightBeaker ? .white : Styling.inactiveScreenElement)
    }

    private func beakerTicks(settings: EnergyBeakerSettings) -> some View {
        BeakerTicks(
            numTicks: settings.beaker.numTicks,
            rightGap: settings.beaker.ticksRightGap,
            bottomGap: settings.beaker.ticksBottomGap,
            topGap: settings.beaker.ticksTopGap,
            minorWidth: settings.beaker.ticksMinorWidth,
            majorWidth: settings.beaker.ticksMajorWidth
        )
        .stroke(lineWidth: 1)
        .fill(Color.darkGray.opacity(0.5))
        .frame(width: settings.beakerWidth, height: settings.beakerHeight)
    }

    private func skSceneView(settings: EnergyBeakerSettings) -> some View {
        GeometryReader { geometry in
            SkBeakerSceneRepresentable(
                width: geometry.size.width,
                height: geometry.size.height,
                waterHeight: settings.waterHeight,
                speed: extraEnergyFactor,
                updateConcentrationC: updateConcentrationC,
                reactionHasStarted: reactionHasStarted,
                emitterPosition: settings.emitterPosition,
                emitting: emitCatalyst,
                catalystColor: catalystState.selected?.color ?? catalystState.pending?.color ?? .black,
                canReactToC: canReactToC,
                reactionHasEnded: reactionHasEnded
            )
        }
        .frame(
            width: settings.beaker.innerBeakerWidth,
            height: settings.skSceneHeight
        )
    }


    private func catalystView(
        settings: EnergyBeakerSettings
    ) -> some View {
        ZStack {
            catImage(index: 0, catalyst: .A, settings: settings)
            catImage(index: 1, catalyst: .B, settings: settings)
            catImage(index: 2, catalyst: .C, settings: settings)
        }
    }

    private func catImage(
        index: Int,
        catalyst: Catalyst,
        settings: EnergyBeakerSettings
    ) -> some View {
        let isSelected = catalystState == .selected(catalyst: catalyst)
        let isInProgress = catalystState == .pending(catalyst: catalyst)
        let hasMoved = isSelected || isInProgress
        let stationaryX = (settings.width / 4) + ((settings.width / 4) * CGFloat(index))
        let x = hasMoved ? settings.width / 2 : stationaryX
        let y = hasMoved ? settings.catHeight : settings.catHeight / 2
        let zIndex: Double = hasMoved ? 1 : 0
        let rotation: Angle = hasMoved ? .degrees(135) : .zero
        let scale: CGFloat = hasMoved ? 1.2 : 1
        let shadow = hasMoved ? settings.catHeight * 0.05 : 0
        let yOffset = (isInProgress && catalystIsShaking)  ? settings.catHeight * 0.1 : 0

        return Image(catalystState != .disabled || isInProgress ? catalyst.imageName : "catdeact")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .rotationEffect(rotation, anchor: .center)
            .position(
                x: x,
                y: y
            )
            .frame(height: settings.catHeight)
            .zIndex(zIndex)
            .shadow(radius: shadow)
            .scaleEffect(x: scale, y: scale, anchor: .top)
            .opacity(isSelected ? 0 : 1)
            .offset(y: yOffset)
            .onTapGesture {
                if (catalystState == .active) {
                    setCatalystInProgress(catalyst)
                } else if (catalystState == .pending(catalyst: catalyst)) {
                    doSelectCatalyst(catalyst: catalyst)
                } else {
                    return
                }
            }
            .onReceive(
                NotificationCenter.default.publisher(
                    for: .deviceDidShakeNotification
                )
            ) { _ in
                doSelectCatalyst(catalyst: catalyst)
            }
    }

    private func doSelectCatalyst(
        catalyst: Catalyst
    ) {
        let inProgress = catalystState.pending == catalyst
        let notSelected = catalystState.selected == nil
        if (canSelectCatalyst && inProgress && notSelected && !emitCatalyst) {
            selectCatalyst(catalyst)
        }
    }

    private func beakerStand(settings: EnergyBeakerSettings) -> some View {
        ZStack(alignment: .bottom) {
            Image("stand")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: settings.standWidth)

            Image("burner")
                .resizable()
                .frame(width: settings.burnerWidth, height: settings.burnerHeight)

            flame(settings: settings)
        }
    }

    private func flame(settings: EnergyBeakerSettings) -> some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                smallFlame(settings: settings)
                    .offset(x: settings.flameWidth)

                smallFlame(settings: settings)
                    .offset(x: -settings.flameWidth)

                flameImage
                    .frame(width: largeFlameWidth(settings: settings))
                    .scaleEffect(
                        x: 1 + flameScale,
                        y: 1 - flameScale,
                        anchor: .bottom
                    )
            }

            Spacer()
                .frame(width: settings.burnerWidth, height: settings.burnerHeight)
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
            .frame(width: largeFlameWidth(settings: settings) * 0.6)
            .scaleEffect(
                x: 1 + flameScale,
                y: 1 - flameScale,
                anchor: .bottom
            )
    }

    private func largeFlameWidth(settings: EnergyBeakerSettings) -> CGFloat {
        let speed = tempFactor(settings: settings)
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
            barColor: Styling.energySliderBar,
            orientation: .landscape,
            includeFill: true,
            useHaptics: false
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

    private func tempFactor(
        settings: EnergyBeakerSettings
    ) -> CGFloat {
        if let temp = temp {
            let numerator = temp - settings.axis.minValue
            let delta = settings.axis.maxValue - settings.axis.minValue
            return numerator / delta
        }
        return 0
    }

    private var isPending: Bool {
        if case .pending = catalystState {
            return true
        }
        return false
    }
}

struct EnergyBeakerSettings {
    let geometry: GeometryProxy

    static let minTemp: CGFloat = 400
    static let maxTemp: CGFloat = 600

    var beaker: BeakerSettings {
        BeakerSettings(width: beakerWidth)
    }

    var width: CGFloat {
        geometry.size.width
    }

    var height: CGFloat {
        geometry.size.height
    }

    let standHeightToWidth: CGFloat = 0.257
    let burnerHeightToWidth: CGFloat = 0.1064

    var axis: AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: geometry.size.width * 0.1,
            maxValuePosition: geometry.size.width * 0.9,
            minValue: EnergyBeakerSettings.minTemp,
            maxValue: EnergyBeakerSettings.maxTemp
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

    var waterHeight: CGFloat {
        0.4 * beakerHeight
    }

    var standWidth: CGFloat {
        beakerWidth
    }

    var standHeight: CGFloat {
        standWidth * standHeightToWidth
    }

    var burnerWidth: CGFloat {
        standWidth * 0.4
    }
    var burnerHeight: CGFloat {
        burnerHeightToWidth * burnerWidth
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
    var shakeFontSize: CGFloat {
        0.23 * catHeight
    }

    var skSceneHeight: CGFloat {
        height - handleThickness - standHeight - sliderTopPadding
    }

    var emitterPosition: CGPoint {
        var y = skSceneHeight - catHeight
        var x = beaker.innerBeakerWidth / 2

        let dh = 0.26 * catHeight // Distance from center to opening of catalyst container
        let dx = dh * CGFloat(cos(Angle.degrees(45).radians))
        let dy = dh * CGFloat(sin(Angle.degrees(45).radians))

        y -= dy
        x += dx
        return CGPoint(x: x, y: y)
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

    var color: UIColor {
        switch(self) {
        case .A: return .catalystA
        case .B: return .catalystB
        case .C: return .catalystC
        }
    }
}

struct EnergyProfileBeaker_Previews: PreviewProvider {
    static var previews: some View {
        EnergyProfileBeaker(
            catalystState: .disabled,
            selectCatalyst: {_ in },
            setCatalystInProgress: {_ in },
            emitCatalyst: false,
            temp: .constant(500),
            extraEnergyFactor: 0,
            updateConcentrationC: {_ in },
            reactionHasStarted: true,
            catalystIsShaking: false,
            canReactToC: true,
            canSelectCatalyst: true,
            reactionHasEnded: false,
            highlightSlider: false,
            highlightBeaker: true
        )
        .background(Styling.inactiveScreenElement)
        .previewLayout(.fixed(width: 200, height: 320))
    }
}
