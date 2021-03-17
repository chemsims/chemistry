//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct PressureBeaker: View {

    let disabled: Bool
    let settings: GaseousReactionScreenSettings
    @State private var tempFactor: CGFloat = 0.5
    @State private var rows: CGFloat = 7

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            pump
            VStack(alignment: .trailing, spacing: 0) {
                beaker
                burner
            }
        }
    }

    private var pump: some View {
        Pump(pumpModel:
                PumpViewModel(
                    initialExtensionFactor: 1,
                    divisions: 10,
                    onDownPump: {}
                )
        )
        .frame(width: settings.pumpWidth, height: settings.pumpHeight)
        .offset(x: settings.pumpXOffset, y: -settings.pumpYOffset)
    }

    private var beaker: some View {
        AdjustableAirBeaker(
            minRows: 7,
            maxRows: 13,
            rows: $rows,
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
            disabled: disabled,
            useHaptics: true,
            highlightSlider: false,
            sliderAccessibilityValue: nil, // TODO
            settings: AdjustableBeakerBurnerSettings(
                standWidth: settings.standWidth,
                handleHeight: settings.sliderWidth,
                axis: AxisPositionCalculations(
                    minValuePosition: 20,
                    maxValuePosition: 150,
                    minValue: 0,
                    maxValue: 1
                )
            )
        )
        .frame(width: settings.standWidth)
//        .offset(x: 50)
    }
}

struct GaseousReactionScreenSettings {
    let beakerWidth: CGFloat

    var standWidth: CGFloat {
        beakerWidth
    }

    var beakerHeight: CGFloat {
        beakerWidth * BeakerSettings.heightToWidth
    }

    var sliderWidth: CGFloat {
        0.11 * standWidth
    }

    var airBeakerTotalWidth: CGFloat {
        1.1 * (beakerWidth + sliderWidth)
    }

    var pumpWidth: CGFloat {
        PumpSettings.widthToHeight * pumpHeight
    }

    var pumpHeight: CGFloat {
        0.6 * beakerHeight
    }

    var pumpYOffset: CGFloat {
        sliderWidth + burnerSettings.sliderTopPadding
    }

    var pumpXOffset: CGFloat {
        airBeakerTotalWidth - beakerWidth
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
        PressureBeaker(
            disabled: false,
            settings: GaseousReactionScreenSettings(beakerWidth: 225)
        )
    }
}
