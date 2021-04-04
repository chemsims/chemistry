//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct SolubilityScreen: View {

    let model: SolubilityViewModel

    var body: some View {
        GeometryReader { geo in
            SolubilityScreenWithSettings(
                model: model,
                settings: SolubilityScreenLayoutSettings(geometry: geo)
            )
        }
    }
}

private struct SolubilityScreenWithSettings: View {

    @ObservedObject var model: SolubilityViewModel
    let settings: SolubilityScreenLayoutSettings

    var body: some View {
        HStack(spacing: 0) {
            SolubleBeakerView(
                waterColor: Styling.beakerLiquid,
                model: SoluteBeakerShakingViewModel(),
                settings: SolubleBeakerSettings(
                    beakerWidth: settings.common.beakerWidth,
                    waterHeight: settings.waterHeightAxis.getPosition(at: model.waterHeightFactor)
                )
            )
            
            Spacer()

            SolubilityRightStack(
                model: model,
                settings: settings.common
            )
        }
    }
}

private struct SolubilityRightStack: View {

    @ObservedObject var model: SolubilityViewModel
    let settings: AqueousScreenLayoutSettings

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            BeakyBox(
                statement: model.statement,
                next: model.next,
                back: model.back,
                nextIsDisabled: false,
                settings: settings.beakySettings
            )
        }

    }
}

private struct SolubilityScreenLayoutSettings {
    let geometry: GeometryProxy

    var common: AqueousScreenLayoutSettings {
        AqueousScreenLayoutSettings(geometry: geometry)
    }

    var waterHeightAxis: AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: 0.4 * common.beakerHeight,
            maxValuePosition:  0.7 * common.beakerHeight,
            minValue: 0,
            maxValue: 1
        )
    }
}

struct SolubilityScreen_Previews: PreviewProvider {
    static var previews: some View {
        SolubilityScreen(model: SolubilityViewModel())
            .previewLayout(.iPhoneSELandscape)
    }
}
