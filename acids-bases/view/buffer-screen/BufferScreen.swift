//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct BufferScreen: View {

    @ObservedObject var model: BufferScreenViewModel

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.white)
                .colorMultiply(model.highlights.colorMultiply(for: nil))
                .edgesIgnoringSafeArea(.all)

            GeometryReader { geo in
                BufferScreenWithSettings(
                    model: model,
                    layout: BufferScreenLayout(
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

private struct BufferScreenWithSettings: View {

    @ObservedObject var model: BufferScreenViewModel
    let layout: BufferScreenLayout

    var body: some View {
        HStack(spacing: 0) {
            BufferBeaker(
                layout: layout,
                model: model
            )
            .accessibilityElement(children: .contain)

            Spacer()

            BufferChartStack(
                layout: layout,
                model: model
            )
            .accessibilityElement(children: .contain)

            Spacer()

            BufferRightStack(
                layout: layout,
                model: model,
                weakModel: model.weakSubstanceModel
            )
        }
    }
}

struct BufferScreenLayout {
    let common: AcidBasesScreenLayout

    var tableSize: CGSize {
        CGSize(
            width: common.chartTotalWidth,
            height: common.chartTotalHeight
        )
    }

    var containerRowYPos: CGFloat {
        common.reactionDefinitionSize.height + (0.6 * common.containerSize.height)
    }

    var activeContainerYPos: CGFloat {
        containerRowYPos + common.containerSize.height
    }

    var equationSize: CGSize {
        let availableWidth = common.width -
            common.beakerWidth -
            common.sliderSettings.handleWidth -
            common.chartTotalWidth
        let availableHeight = common.height - common.beakyBoxHeight - common.toggleHeight
        return CGSize(
            width: 0.9 * availableWidth,
            height: 0.9 * availableHeight
        )
    }
}

struct BufferScreen_Previews: PreviewProvider {
    static var previews: some View {
        BufferScreen(
            model: BufferScreenViewModel(
                substancePersistence: InMemoryAcidOrBasePersistence(),
                namePersistence: InMemoryNamePersistence()
            )
        )
        .padding()
        .previewLayout(.iPhone12ProMaxLandscape)
    }
}
