//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct IntroScreen: View {

    @ObservedObject var model: IntroScreenViewModel

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.white)
                .colorMultiply(model.highlights.colorMultiply(for: nil))
                .edgesIgnoringSafeArea(.all)

            GeometryReader { geo in
                IntroScreenWithSettings(
                    model: model,
                    layout: IntroScreenLayout(
                        common: AcidBasesScreenLayout(
                            geometry: geo,
                            verticalSizeClass: verticalSizeClass,
                            horizontalSizeClass: horizontalSizeClass
                        )
                    )
                )
            }
            .padding(AcidBasesScreenLayout.topLevelScreenPadding)
        }
    }
}

struct IntroScreenWithSettings: View {

    @ObservedObject var model: IntroScreenViewModel
    let layout: IntroScreenLayout

    var body: some View {
        HStack(spacing: 0) {
            IntroBeaker(
                model: model,
                components: model.components,
                layout: layout
            )
            Spacer()
            IntroRightStack(
                model: model,
                components: model.components,
                layout: layout
            )
        }
    }
}

struct IntroScreenLayout {
    let common: AcidBasesScreenLayout
}


// MARK: Left stack layout
extension IntroScreenLayout {
    var containerRowYPos: CGFloat {
        common.reactionDefinitionSize.height + (0.6 * common.phMeterSize.height)
    }

    var activeContainerYPos: CGFloat {
        containerRowYPos + common.containerSize.height
    }
}

// MARK: PH bar layout
extension IntroScreenLayout {

    var phScaleSize: CGSize {
        CGSize(
            width: 0.95 * common.rightColumnWidth,
            height: 0.3 * common.height
        )
    }

    var phBarBottomPadding: CGFloat {
        0.05 * phScaleSize.height
    }

    var phBarTopPadding: CGFloat {
        phBarBottomPadding
    }

    var phAreaTotalHeight: CGFloat {
        phScaleSize.height + phBarTopPadding + phBarBottomPadding + toggleHeight
    }

    var toggleFontSize: CGFloat {
        let phGeometry = PHScaleGeometry(
            width: phScaleSize.width,
            height: phScaleSize.height,
            tickCount: 14,
            topLeftTickValue: 0,
            topRightTickValue: 1
        )
        return phGeometry.labelsFontSize
    }

    var toggleHeight: CGFloat {
        1.2 * toggleFontSize
    }
}

// MARK: Chart layout
extension IntroScreenLayout {
    var chartToggleSpacing: CGFloat {
        5
    }

    /// The chart area height - i.e., the larger of the total chart height or the beaky box height
    var chartAreaTotalHeight: CGFloat {
        max(barChartTotalHeight, common.beakyBoxHeight)
    }

    var barChartTotalWidth: CGFloat {
        common.chartTotalWidth
    }

    private var barChartTotalHeight: CGFloat {
        common.barChartSettings.totalHeight + chartToggleSpacing + toggleHeight
    }
}

// MARK: Equation layout
extension IntroScreenLayout {
    var equationSize: CGSize {

        let availableHeight = common.height - chartAreaTotalHeight - phAreaTotalHeight

        let availableWidth = common.rightColumnWidth - common.toggleHeight

        return CGSize(
            width: 0.9 * availableWidth,
            height: availableHeight
        )
    }
}

struct IntroScreen_Previews: PreviewProvider {
    static var previews: some View {
        IntroScreen(
            model: IntroScreenViewModel(
                substancePersistence: InMemoryAcidOrBasePersistence(),
                namePersistence: InMemoryNamePersistence()
            )
        )
            .previewLayout(.iPhone8Landscape)
    }
}
