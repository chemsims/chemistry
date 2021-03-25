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
        }
        .disabled(model.inputState != .addReactants)
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
            highlightSlider: false,
            showFlame: model.showFlame,
            sliderAccessibilityValue: nil, // TODO
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
                settings: PressureBeakerSettings(width: geo.size.width)
            )
        }
    }
}
