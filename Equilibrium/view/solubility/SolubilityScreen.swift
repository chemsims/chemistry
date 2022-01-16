//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct SolubilityScreen: View {

    @ObservedObject var model: SolubilityViewModel
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.white)
                .colorMultiply(model.highlights.colorMultiply(for: nil))
                .edgesIgnoringSafeArea(.all)

            GeometryReader { geometry in
                SolubilityScreenWithSettings(
                    model: model,
                    settings: SolubilityScreenLayoutSettings(
                        geometry: geometry,
                        verticalSizeClass: verticalSizeClass,
                        horizontalSizeClass: horizontalSizeClass
                    )
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
            SolubleReactionDefinitionView(
                reaction: model.selectedReaction,
                direction: model.reactionArrowDirection,
                arrowWidth: 1.3 * settings.common.shakeTextFontSize,
                fontSize: 1.3 * settings.common.shakeTextFontSize
            )
            .id(model.selectedReaction.rawValue)
            .transition(.identity)
            .padding(.top, settings.reactionDefinitionTopPadding)

            SolubleBeakerView(
                model: model,
                shakeModel: model.shakingModel,
                settings: settings
            )
            .frame(width: settings.totalBeakerWidth)
            .accessibilityElement(children: .contain)
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
            branchMenu
        }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            reactionToggle

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
                lineWidth: settings.common.chartSettings.axisShapeSettings.lineWidth,
                indicatorRadius: settings.common.chartSettings.headRadius,
                haloRadius: settings.common.chartSettings.layout.haloRadius
            )
            .frame(width: settings.phPlotWidth, height: settings.phPlotHeight)
            .font(.system(size: settings.common.chartSettings.axisLabelFontSize))
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
        .padding(.trailing, settings.common.branchMenu.width + settings.common.branchMenuHSpacing)
    }

    private var branchMenu: some View {
        BranchMenu(layout: settings.common.branchMenu)
            .spacing(horizontalAlignment: .trailing, verticalAlignment: .top)
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
    let verticalSizeClass: UserInterfaceSizeClass?
    let horizontalSizeClass: UserInterfaceSizeClass?

    var common: EquilibriumAppLayoutSettings {
        EquilibriumAppLayoutSettings(
            geometry: geometry,
            verticalSizeClass: verticalSizeClass,
            horizontalSizeClass: horizontalSizeClass
        )
    }

    var waterHeightAxis: LinearAxis<CGFloat> {
        LinearAxis(
            minValuePosition: minWaterHeightFraction * common.beakerHeight,
            maxValuePosition: maxWaterHeightFraction * common.beakerHeight,
            minValue: 0,
            maxValue: 1
        )
    }

    let minWaterHeightFraction = SolubleReactionSettings.minWaterHeight
    let maxWaterHeightFraction = SolubleReactionSettings.maxWaterHeight

    var soluble: SolubleBeakerSettings {
        SolubleBeakerSettings(
            common: common,
            definitionTopPadding: reactionDefinitionTopPadding
        )
    }

    var reactionDefinitionTopPadding: CGFloat {
        if verticalSizeClass.contains(.regular) {
            return common.chartSelectionHeight
        }
        return 0
    }

    var equationWidth: CGFloat {
        common.equationWidth
    }

    var equationHeight: CGFloat {
        common.equationHeight
    }

    var phPlotWidth: CGFloat {
        if horizontalSizeClass.contains(.regular) {
            return common.equationWidth
        }
        return 0.8 * common.equationWidth
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

    var milligramLabelFontSize: CGFloat {
        0.75 * soluble.containerWidth
    }

    var milligramNumberFrameSize: CGSize {
        CGSize(
            width: 2.4 * soluble.containerWidth,
            height: 1.2 * soluble.containerWidth
        )
    }

    var reactionDefinitionPopupFontSize: CGFloat {
        0.7 * milligramLabelFontSize
    }

    var reactionDefinitionPopupSize: CGSize {
        CGSize(
            width: 2.1 * milligramNumberFrameSize.width,
            height: milligramNumberFrameSize.height
        )
    }
}

struct SolubilityScreen_Previews: PreviewProvider {
    static var previews: some View {
        SolubilityScreen(
            model: SolubilityViewModel(
                persistence: InMemorySolubilityPersistence()
            )
        )
        .previewLayout(.iPadPro12_9Inch)
    }
}
