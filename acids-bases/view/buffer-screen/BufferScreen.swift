//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct BufferScreen: View {

    let model: BufferScreenViewModel

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
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
        .padding(15) // TODO - get rid of this
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
            Spacer()
            BufferChartStack(
                layout: layout,
                model: model
            )
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
        50
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
        BufferScreen(model: BufferScreenViewModel())
            .padding()
            .previewLayout(.iPhone12ProMaxLandscape)
    }
}
