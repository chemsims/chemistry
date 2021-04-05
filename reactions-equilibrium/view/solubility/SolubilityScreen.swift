//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct SolubilityScreen: View {

    let model: SolubilityViewModel

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.white)
                .colorMultiply(.white)
                .edgesIgnoringSafeArea(.all)

            GeometryReader { geometry in
                SolubilityScreenWithSettings(
                    model: model,
                    settings: SolubilityScreenLayoutSettings(geometry: geometry)
                )
            }
            .padding(10)
        }
    }
}

private struct SolubilityScreenWithSettings: View {

    @ObservedObject var model: SolubilityViewModel
    let settings: SolubilityScreenLayoutSettings

    var body: some View {
        HStack(spacing: 0) {
            SolubleBeakerView(
                model: model,
                shakeModel: model.shakingModel,
                settings: settings
            )

            ChartStack(
                model: model,
                currentTime: $model.currentTime,
                activeChartIndex: .constant(nil),
                settings: settings.common
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

struct SolubilityScreenLayoutSettings {
    let geometry: GeometryProxy

    var common: AqueousScreenLayoutSettings {
        AqueousScreenLayoutSettings(geometry: geometry)
    }

    var waterHeightAxis: AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: SolubleReactionSettings.minWaterHeight * common.beakerHeight,
            maxValuePosition:  SolubleReactionSettings.maxWaterHeight * common.beakerHeight,
            minValue: 0,
            maxValue: 1
        )
    }

    var soluble: SolubleBeakerSettings {
        SolubleBeakerSettings(beakerWidth: common.beakerWidth)
    }

}

struct SolubilityScreen_Previews: PreviewProvider {
    static var previews: some View {
        SolubilityScreen(model: SolubilityViewModel())
            .previewLayout(.iPhoneSELandscape)
    }
}
