//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct SolubilityScreen: View {

    @ObservedObject var model: SolubilityViewModel

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.white)
                .colorMultiply(model.highlights.colorMultiply(for: nil))
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

            leftStack
                .zIndex(2)

            Spacer()

            ChartStack(
                model: model,
                currentTime: $model.currentTime,
                settings: settings.common
            )

            Spacer()

            SolubilityRightStack(
                model: model,
                settings: settings
            )
        }
    }

    private var leftStack: some View {
        VStack(spacing: 0) {
            ReactionDefinitionView(
                type: model.selectedReaction,
                runForwardArrow: model.highlightForwardReactionArrow,
                runReverseArrow: false,
                arrowWidth: 1.3 * settings.common.shakeTextFontSize
            )
            .id(model.selectedReaction.rawValue)
            .transition(.identity)
            .font(.system(size: 1.3 * settings.common.shakeTextFontSize))

            SolubleBeakerView(
                model: model,
                shakeModel: model.shakingModel,
                settings: settings
            )
            .frame(width: settings.totalBeakerWidth)
        }
        .padding(.leading, settings.common.menuSize)
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
            reactionToggle
                .accessibility(sortPriority: -1)

            Spacer()

            SolubilityEquationView(model: model)
                .frame(
                    width: settings.equationWidth,
                    height: settings.equationHeight
                )

            Spacer()

            SolubilityPhChart(
                curve: model.selectedReaction.solubility.curve,
                startPh: model.selectedReaction.solubility.startingPh,
                ph: model.componentsWrapper.ph,
                solubility: model.componentsWrapper.solubility,
                currentTime: model.currentTime,
                lineWidth: settings.common.chartSettings.layout.lineWidth,
                indicatorRadius: settings.common.chartSettings.headRadius,
                haloRadius: settings.common.chartSettings.layout.haloRadius

            )
            .frame(width: settings.phPlotWidth, height: settings.phPlotHeight)
            .font(.system(size: settings.phPlotFontSize))
            .opacity(model.equationState == .showOriginalQuotientAndQuotientRecap ? 0 : 1)

            Spacer()

            BeakyBox(
                statement: model.statement,
                next: model.next,
                back: model.back,
                nextIsDisabled: model.nextIsDisabled,
                settings: settings.common.beakySettings
            )
        }
    }

    private var reactionToggle: some View {
        ReactionToggle(
            reactions: SolubleReactionType.allCases,
            selectedReaction: $model.selectedReaction,
            reactionSelectionIsToggled: $model.reactionSelectionToggled,
            isSelectingReaction: model.inputState == .selectingReaction,
            onSelection: model.next,
            reactionToggleHighlight: model.highlights.colorMultiply(for: .reactionSelectionToggle),
            settings: settings.common
        )
    }

    private var equationRecap: some View {
        VStack(spacing: 0) {
            Spacer()
            SolubilityQuotientRecapEquations(reaction: model.selectedReaction)
                .frame(width: settings.equationWidth, height: settings.equationHeight)
                .background(
                    Color.white
                        .padding(-0.05 * settings.equationHeight)
                )
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
            minValuePosition: minWaterHeightFraction * common.beakerHeight,
            maxValuePosition: maxWaterHeightFraction * common.beakerHeight,
            minValue: 0,
            maxValue: 1
        )
    }

    let minWaterHeightFraction = SolubleReactionSettings.minWaterHeight
    let maxWaterHeightFraction = SolubleReactionSettings.maxWaterHeight

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

    var totalBeakerWidth: CGFloat {
        common.beakerWidth + common.sliderSettings.handleWidth
    }

}

struct SolubilityScreen_Previews: PreviewProvider {
    static var previews: some View {
        SolubilityScreen(model: SolubilityViewModel())
            .previewLayout(.iPhone8Landscape)
    }
}
