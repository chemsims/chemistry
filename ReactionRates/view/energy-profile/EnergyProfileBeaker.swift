//
// Reactions App
//

import SwiftUI
import ReactionsCore

// TODO - refactor this to just take the energy view model as input, rather than so many variables 
struct EnergyProfileBeaker: View {

    let reactionState: EnergyReactionState
    let catalystState: CatalystState
    let selectCatalyst: (Catalyst) -> Void
    let setCatalystInProgress: (Catalyst) -> Void

    let particleState: CatalystParticleState

    @Binding var temp: CGFloat?
    let extraEnergyFactor: CGFloat
    let updateConcentrationC: (CGFloat) -> Void
    let catalystIsShaking: Bool

    let canReactToC: Bool
    let canSelectCatalyst: Bool
    let highlightSlider: Bool
    let highlightBeaker: Bool
    let highlightCatalyst: Bool

    let availableCatalysts: [Catalyst]
    let usedCatalysts: [Catalyst]

    let reactionInput: EnergyProfileReactionInput

    let catalystColor: UIColor
    let order: ReactionOrder
    let concentrationC: CGFloat

    let chartInput: EnergyProfileChartInput

    @State private var flameScale: CGFloat = 0
    private let tripleFlameThreshold: CGFloat = 500

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
        .accessibilityElement(children: .contain)
    }

    private func shakeText(settings: EnergyBeakerSettings) -> some View {
        HStack {
            Spacer()
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: settings.catHeight)
                ShakeText()
            }
            .font(.system(size: settings.shakeFontSize))
        }
        .accessibility(hidden: true)
    }

    private func stackView(settings: EnergyBeakerSettings) -> some View {
        let temp = tempBinding ?? .constant(settings.axis.minValue)
        return VStack(spacing: 0) {
            beakerView(settings: settings)
                .frame(width: settings.beakerWidth, height: settings.skSceneHeight)

            AdjustableBeakerBurner(
                temp: temp,
                disabled: tempIsDisabled,
                useHaptics: false,
                highlightSlider: highlightSlider,
                showFlame: true,
                sliderAccessibilityValue: getSliderAccessibilityValue(
                    temp: temp,
                    settings: settings
                ),
                generalColorMultiply: .white,
                sliderColorMultiply: .white,
                settings: AdjustableBeakerBurnerSettings(
                    standWidth: settings.standWidth,
                    handleHeight: settings.handleHeight,
                    axis: settings.axis
                )
            )
        }
    }

    private func getSliderAccessibilityValue(
        temp: Binding<CGFloat>?,
        settings: EnergyBeakerSettings
    ) -> String {
        let currentValue = temp?.wrappedValue ?? settings.axis.minValue
        let fraction = (currentValue - settings.axis.minValue) / (settings.axis.maxValue - settings.axis.minValue)
        let percent = fraction.percentage

        let position = chartInput.canReactToC ? "above" : "below"
        let positionMsg = temp == nil ? "" : ", current energy is \(position) EA hump"

        return "\(currentValue.str(decimals: 0)), \(percent)\(positionMsg)"
    }

    private func beakerView(
        settings: EnergyBeakerSettings
    ) -> some View {
        let input = order.energyProfileReactionInput
        let a = input.moleculeA.name
        let b = input.moleculeB.name
        let c = input.moleculeC.name

        let perc = (concentrationC * 100).str(decimals: 0)
        let value = "Concentration of \(c) is \(perc)%"

        let catalyst = catalystState.selected?.rawValue
        let catalystMsg = catalyst.map { ", with catalyst \($0) particles also in the beaker" } ?? ""
        let label = "Beaker with molecules of \(a) and \(b) colliding which occasionally produces a molecule of \(c)\(catalystMsg)"

        return FillableBeaker(
            waterColor: Styling.beakerLiquid,
            waterHeight: settings.waterHeight,
            highlightBeaker: highlightBeaker,
            settings: settings.fillableBeaker
        ) {
            skSceneView(settings: settings)
        }
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text(label))
        .accessibility(value: Text(value))
        .accessibility(addTraits: .updatesFrequently)
    }

    private func skSceneView(settings: EnergyBeakerSettings) -> some View {
        GeometryReader { geometry in
            SkBeakerSceneRepresentable(
                width: geometry.size.width,
                height: geometry.size.height,
                waterHeight: settings.waterHeight,
                speed: extraEnergyFactor,
                updateConcentrationC: updateConcentrationC,
                emitterPosition: settings.emitterPosition,
                particleState: particleState,
                catalystColor: catalystColor,
                canReactToC: canReactToC,
                reactionState: reactionState,
                input: reactionInput
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
        let rotation: Angle = hasMoved ? .degrees(135) : .zero
        let scale: CGFloat = hasMoved ? 1.2 : 1
        let shadow = hasMoved ? settings.catHeight * 0.05 : 0
        let yOffset = (isInProgress && catalystIsShaking && !reduceMotion)  ? settings.catHeight * 0.1 : 0
        let shouldHighlight = highlightCatalyst && availableCatalysts.contains(catalyst)

        let labelSuffix = isInProgress ? ". Rotated above beaker, preparing to drop catalyst particles" : ""
        let label = "Catalyst container \(catalyst.rawValue)\(labelSuffix)"

        return Image(
            catalystState == .disabled ? "catdeact" : catalyst.imageName,
            bundle: .reactionRates
        )
            .resizable()
            .aspectRatio(contentMode: .fit)
            .rotationEffect(rotation, anchor: .center)
            .position(
                x: x,
                y: y
            )
            .frame(height: settings.catHeight)
            .zIndex(index == 1 ? 0 : 1)
            .shadow(radius: shadow)
            .scaleEffect(x: scale, y: scale, anchor: .top)
            .opacity(isSelected || usedCatalysts.contains(catalyst) ? 0 : 1)
            .offset(y: yOffset)
            .opacity(availableCatalysts.contains(catalyst) ? 1 : 0.2)
            .onTapGesture {
                if catalystState == .active {
                    setCatalystInProgress(catalyst)
                } else if catalystState == .pending(catalyst: catalyst) {
                    doSelectCatalyst(catalyst: catalyst)
                } else {
                    return
                }
            }
            .colorMultiply(shouldHighlight ? .white : Styling.inactiveScreenElement)
            .onReceive(
                NotificationCenter.default.publisher(
                    for: .deviceDidShakeNotification
                )
            ) { _ in
                doSelectCatalyst(catalyst: catalyst)
            }
            .accessibility(label: Text(label))
            .accessibility(addTraits: .isButton)
            .disabled(catalystIsDisabled(catalyst))
    }

    private func catalystIsDisabled(_ catalyst: Catalyst) -> Bool {
        catalystState != .active && catalystState != .pending(catalyst: catalyst)
    }

    private func doSelectCatalyst(
        catalyst: Catalyst
    ) {
        let inProgress = catalystState.pending == catalyst
        if canSelectCatalyst && inProgress && particleState == .none {
            selectCatalyst(catalyst)
        }
    }

    private func burner(settings: EnergyBeakerSettings) -> some View {
        let currentValue = temp ?? settings.axis.minValue
        let fraction = (currentValue - settings.axis.minValue) / (settings.axis.maxValue - settings.axis.minValue)
        let percent = (fraction * 100).str(decimals: 0)

        let position = chartInput.canReactToC ? "above" : "below"
        let positionMsg = temp == nil ? "" : ", current energy is \(position) EA hump"
        let accessibilityValue = "\(currentValue.str(decimals: 0)), \(percent)%\(positionMsg)"

        return AdjustableBeakerBurner(
            temp: tempBinding ?? .constant(settings.axis.minValue),
            disabled: tempIsDisabled,
            useHaptics: false,
            highlightSlider: highlightSlider,
            showFlame: true,
            sliderAccessibilityValue: accessibilityValue,
            generalColorMultiply: .white,
            sliderColorMultiply: .white,
            settings: AdjustableBeakerBurnerSettings(
                standWidth: settings.standWidth,
                handleHeight: settings.handleHeight,
                axis: settings.axis
            )
        )
    }

    private var tempIsDisabled: Bool {
        tempBinding == nil || reactionState == .pending
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
        fillableBeaker.beaker
    }

    var fillableBeaker: FillableBeakerSettings {
        FillableBeakerSettings(beakerWidth: beakerWidth)
    }

    var width: CGFloat {
        geometry.size.width
    }

    var height: CGFloat {
        geometry.size.height
    }

    let standHeightToWidth: CGFloat = 0.257
    let burnerHeightToWidth: CGFloat = 0.1064

    var axis: LinearAxis<CGFloat> {
        LinearAxis(
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
        switch self {
        case .A: return "catone"
        case .B: return "cattwo"
        case .C: return "catthree"
        }
    }

    var color: UIColor {
        switch self {
        case .A: return .catalystA
        case .B: return .catalystB
        case .C: return .catalystC
        }
    }
}

struct EnergyProfileBeaker_Previews: PreviewProvider {
    static var previews: some View {
        EnergyProfileBeaker(
            reactionState: .pending,
            catalystState: .disabled,
            selectCatalyst: {_ in },
            setCatalystInProgress: {_ in },
            particleState: .none,
            temp: .constant(500),
            extraEnergyFactor: 0,
            updateConcentrationC: {_ in },
            catalystIsShaking: false,
            canReactToC: true,
            canSelectCatalyst: true,
            highlightSlider: false,
            highlightBeaker: true,
            highlightCatalyst: false,
            availableCatalysts: Catalyst.allCases,
            usedCatalysts: [],
            reactionInput: ReactionOrder.Zero.energyProfileReactionInput,
            catalystColor: .blue,
            order: .Zero,
            concentrationC: 0.4,
            chartInput: .init(
                shape: ReactionOrder.Zero.energyProfileShapeSettings,
                temperature: 400,
                catalyst: .A
            )
        )
        .background(Styling.inactiveScreenElement)
        .previewLayout(.fixed(width: 200, height: 320))
    }
}
