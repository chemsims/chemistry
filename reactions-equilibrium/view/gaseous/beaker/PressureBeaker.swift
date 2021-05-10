//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct PressureBeaker: View {

    @ObservedObject var model: GaseousReactionViewModel
    let settings: PressureBeakerSettings

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            pump
            VStack(alignment: .trailing, spacing: 0) {
                beaker
                burner
            }
        }
        .frame(width: settings.width, alignment: .trailing)
    }

    private var pump: some View {
        VStack(alignment: .leading, spacing: settings.switchSpacing) {
            Pump(pumpModel: model.pumpModel)
                .frame(width: settings.pumpWidth, height: settings.pumpHeight)
                .offset(x: settings.pumpXOffset)
                .accessibilityElement(children: .ignore)
                .accessibility(label: Text("Pump connected to beaker"))
                .accessibilityPumpReactant(enabled: model.inputState == .addReactants, add: pumpReactant)

            SlidingSwitch(
                selected: $model.selectedPumpReactant,
                backgroundColor: Styling.switchBackground,
                fontColor: .white,
                leftSettings: AqueousMoleculeReactant.A.switchSettings,
                rightSettings:  AqueousMoleculeReactant.B.switchSettings
            )
            .font(.system(size: settings.switchFontSize))
            .frame(width: settings.switchWidth, height: settings.switchHeight)
            .offset(x: settings.switchXOffset)
            .accessibility(hidden: true)
        }
        .disabled(model.inputState != .addReactants)
        .background(
            Color
                .white
                .padding(-5)
                .offset(x: settings.pumpXOffset)
        )
        .colorMultiply(model.highlightedElements.colorMultiply(for: .pump))
    }

    private var beaker: some View {
        AdjustableAirBeaker(
            molecules: [],
            animatingMolecules: model.components.beakerMolecules.map(\.animatingMolecules),
            currentTime: model.currentTime,
            minRows: GaseousReactionSettings.minRows,
            maxRows: GaseousReactionSettings.maxRows,
            dynamicMinRows: model.componentWrapper.minBeakerRows,
            rows: $model.rows,
            disabled: model.inputState != .setBeakerVolume,
            generalColorMultiply: model.highlightedElements.colorMultiply(for: nil),
            sliderColorMultiply: model.highlightedElements.colorMultiply(for: .pressureSlider),
            highlightSlider: model.highlightedElements.highlight(.pressureSlider),
            settings: AdjustableAirBeakerSettings(
                beakerWidth: settings.beakerWidth,
                sliderWidth: settings.sliderWidth
            )
        )
        .frame(width: settings.airBeakerTotalWidth, height: settings.beakerHeight)
    }

    private var burner: some View {
        AdjustableBeakerBurner(
            temp: $model.extraHeatFactor,
            disabled: model.inputState != .setTemperature,
            useHaptics: true,
            highlightSlider: model.highlightedElements.highlight(.tempSlider),
            showFlame: model.showFlame,
            sliderAccessibilityValue: model.extraHeatFactor.percentage,
            generalColorMultiply: model.highlightedElements.colorMultiply(for: nil),
            sliderColorMultiply: model.highlightedElements.colorMultiply(for: .tempSlider),
            settings: AdjustableBeakerBurnerSettings(
                standWidth: settings.standWidth,
                handleHeight: settings.sliderWidth,
                axis: AxisPositionCalculations(
                    minValuePosition: settings.sliderValuePadding,
                    maxValuePosition: settings.standWidth - settings.sliderValuePadding,
                    minValue: 0,
                    maxValue: 1
                )
            )
        )
        .frame(width: settings.standWidth)
    }

    private func pumpReactant(reactant: AqueousMoleculeReactant, amount: Int) {
        model.incrementReactant(reactant, amount: amount)
    }
}

private extension View {
    func accessibilityPumpReactant(
        enabled: Bool,
        add: @escaping (AqueousMoleculeReactant, Int) -> Void
    ) -> some View {
        self.modifyIf(enabled) {
            $0.modifier(PumpAddReactantModifier(molecule: .A, add: add))
        }.modifyIf(enabled) {
            $0.modifier(PumpAddReactantModifier(molecule: .B, add: add))
        }
    }
}

private struct PumpAddReactantModifier: ViewModifier {
    let molecule: AqueousMoleculeReactant
    let add: (AqueousMoleculeReactant, Int) -> Void

    func body(content: Content) -> some View {
        content
            .modifier(PumpActionModifier(molecule: molecule, amount: 5, add: add))
            .modifier(PumpActionModifier(molecule: molecule, amount: 15, add: add))
    }
}

private struct PumpActionModifier: ViewModifier {

    let molecule: AqueousMoleculeReactant
    let amount: Int
    let add: (AqueousMoleculeReactant, Int) -> Void

    func body(content: Content) -> some View {
        content.accessibilityAction(
            named: Text("Pump \(amount) \(molecule.rawValue) molecules into the beaker")
        ) {
            add(molecule, amount)
        }
    }
}

private extension AqueousMoleculeReactant {
    var switchSettings: SwitchOptionSettings<AqueousMoleculeReactant> {
        switch self {
        case .A:
            return SwitchOptionSettings(
                value: .A,
                color: AqueousMolecule.A.color,
                label: "A"
            )
        case .B:
            return SwitchOptionSettings(
                value: .B,
                color: AqueousMolecule.B.color,
                label: "B"
            )
        }
    }
}

struct PressureBeakerSettings {

    let width: CGFloat

    var beakerWidth: CGFloat {
        0.65 * width
    }

    var standWidth: CGFloat {
        beakerWidth
    }

    var beakerHeight: CGFloat {
        beakerWidth * BeakerSettings.heightToWidth
    }

    var sliderWidth: CGFloat {
        0.06 * width
    }

    var beakerSliderSpacing: CGFloat {
        sliderWidth
    }

    var airBeakerTotalWidth: CGFloat {
        beakerWidth + beakerSliderSpacing + sliderWidth
    }

    var pumpWidth: CGFloat {
        width - beakerWidth
    }

    var pumpHeight: CGFloat {
        PumpSettings.heightToWidth * pumpWidth
    }

    var pumpXOffset: CGFloat {
        airBeakerTotalWidth - beakerWidth
    }

    var sliderValuePadding: CGFloat {
        0.1 * standWidth
    }

    var switchHeight: CGFloat {
        0.14 * pumpHeight
    }

    var switchSpacing: CGFloat {
        0.5 * switchHeight
    }

    var switchWidth: CGFloat {
        2 * switchHeight
    }

    var switchFontSize: CGFloat {
        0.8 * switchHeight
    }

    var switchXOffset: CGFloat {
        let midPumpPosition = PumpSettings.midPumpToWidth * pumpWidth
        let extraOffset = midPumpPosition - (switchWidth / 2)
        return pumpXOffset + extraOffset
    }

    var burnerSettings: AdjustableBeakerBurnerSettings {
        AdjustableBeakerBurnerSettings(
            standWidth: standWidth,
            handleHeight: sliderWidth,
            axis: AxisPositionCalculations(
                minValuePosition: 20,
                maxValuePosition: 150,
                minValue: 0,
                maxValue: 1
            )
        )
    }
}

struct PressureBeaker_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            PressureBeaker(
                model: GaseousReactionViewModel(),
                settings: PressureBeakerSettings(
                    width: GaseousReactionScreenSettings(
                        geometry: geo,
                        verticalSizeClass: nil,
                        horizontalSizeClass: nil
                    ).pressureBeakerSettings.width
                )
            )
            .padding(10)
        }
        .previewLayout(.iPhone12ProMaxLandscape)
    }
}
