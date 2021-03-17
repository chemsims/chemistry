//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct PressureBeaker: View {

    @ObservedObject var model: GaseousReactionViewModel
    let settings: PressureBeakerSettings

    @State private var tempFactor: CGFloat = 0.5

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
        Pump(pumpModel: model.pumpModel)
        .frame(width: settings.pumpWidth, height: settings.pumpHeight)
        .offset(x: settings.pumpXOffset, y: -settings.pumpYOffset)
    }

    private var beaker: some View {
        AdjustableAirBeaker(
            molecules: model.components.nonAnimatingMolecules,
            animatingMolecules: model.components.animatingMolecules,
            minRows: GaseousReactionSettings.minRows,
            maxRows: GaseousReactionSettings.maxRows,
            rows: $model.rows,
            settings: AdjustableAirBeakerSettings(
                beakerWidth: settings.beakerWidth,
                sliderWidth: settings.sliderWidth
            )
        )
        .frame(width: settings.airBeakerTotalWidth, height: settings.beakerHeight)
    }

    private var burner: some View {
        AdjustableBeakerBurner(
            temp: $tempFactor,
            disabled: false,
            useHaptics: true,
            highlightSlider: false,
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

    var pumpYOffset: CGFloat {
        sliderWidth + burnerSettings.sliderTopPadding
    }

    var pumpXOffset: CGFloat {
        airBeakerTotalWidth - beakerWidth
    }

    var sliderValuePadding: CGFloat {
        0.1 * standWidth
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
