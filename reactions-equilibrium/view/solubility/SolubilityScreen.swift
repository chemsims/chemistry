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
            .padding(.leading, settings.common.menuSize)

            Spacer()

            ChartStack(
                model: model,
                currentTime: $model.currentTime,
                activeChartIndex: .constant(nil),
                settings: settings.common
            )

            Spacer()

            SolubilityRightStack(
                model: model,
                settings: settings
            )
        }
    }
}

private struct SolubilityRightStack: View {

    @ObservedObject var model: SolubilityViewModel
    let settings: SolubilityScreenLayoutSettings

    var body: some View {
        ZStack {
            mainContent
            if model.equationState == .showOriginalQuotientAndQuotientRecap {
                equationRecap
                    .transition(.identity)
            }
        }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            SolubilityEquationView(model: model)
                .frame(
                    width: settings.equationWidth,
                    height: settings.equationHeight
                )

            Spacer()

            SolubilityPhChart(
                curve: SolubleReactionSettings.PhCurve.curve,
                startPh: SolubleReactionSettings.startingPh,
                ph: model.componentsWrapper.ph,
                solubility: model.componentsWrapper.solubility,
                currentTime: model.currentTime,
                lineWidth: settings.common.chartSettings.layout.lineWidth,
                indicatorRadius: settings.common.chartSettings.headRadius,
                haloRadius: settings.common.chartSettings.layout.haloRadius

            )
            .frame(width: settings.phPlotWidth, height: settings.phPlotHeight)
            .font(.system(size: settings.phPlotFontSize))
            .opacity(model.equationState.doShowCorrectQuotient ? 1 : 0)

            Spacer()

            BeakyBox(
                statement: model.statement,
                next: model.next,
                back: model.back,
                nextIsDisabled: false,
                settings: settings.common.beakySettings
            )
        }
    }

    private var equationRecap: some View {
        VStack(spacing: 0) {
            Spacer()
            SolubilityQuotientRecapEquations()
                .frame(width: settings.equationWidth, height: settings.equationHeight)
            Spacer()
                .frame(height: 1.1 * settings.common.beakyTotalHeight)
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

    var equationWidth: CGFloat {
        common.equationWidth
    }

    var equationHeight: CGFloat {
        common.equationHeight
    }

    var phPlotWidth: CGFloat {
        0.8 * common.equationWidth
    }

    var phPlotHeight: CGFloat {
        1.2 * equationHeight
    }

    var phPlotFontSize: CGFloat {
        common.chartSelectionFontSize
    }

}

struct SolubilityScreen_Previews: PreviewProvider {
    static var previews: some View {
        SolubilityScreen(model: SolubilityViewModel())
            .previewLayout(.iPhoneSELandscape)
    }
}
