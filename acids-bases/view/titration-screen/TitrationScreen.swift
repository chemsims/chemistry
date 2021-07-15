//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct TitrationScreen: View {

    let model: TitrationViewModel
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        GeometryReader { geo in
            TitrationScreenWithSettings(
                model: model,
                layout: TitrationScreenLayout(
                    common: AcidBasesScreenLayout(
                        geometry: geo,
                        verticalSizeClass: verticalSizeClass,
                        horizontalSizeClass: horizontalSizeClass
                    )
                )
            )
        }
        .padding(10)
    }
}

private struct TitrationScreenWithSettings: View {

    @ObservedObject var model: TitrationViewModel
    let layout: TitrationScreenLayout

    var body: some View {
        HStack(spacing: 0) {
            TitrationBeaker(layout: layout, model: model)
            Spacer(minLength: 0)
            TitrationChartStack(layout: layout, model: model)
            Spacer(minLength: 0)
            TitrationRightStack(
                layout: layout,
                model: model
            )
        }
    }
}

struct TitrationScreenLayout {
    let common: AcidBasesScreenLayout

    var equationSize: CGSize {
        let availableHeight = common.height - common.beakyBoxHeight - reactionDefinitionSize.height
        return CGSize(
            width: 0.9 * availableRightStackWidth,
            height: 0.9 * availableHeight
        )
    }

    var reactionDefinitionSize: CGSize {
        CGSize(
            width: 0.8 * availableRightStackWidth,
            height: 2 * common.toggleHeight
        )
    }

    private var availableRightStackWidth: CGFloat {
        let beakerWidth = common.beakerWidth + common.sliderSettings.handleWidth
        let chartsWidth = common.chartSize

        return common.width - beakerWidth - chartsWidth
    }

    /// Height of the water from the bottom of the beaker
    func waterHeight(forRows rows: CGFloat) -> CGFloat {
        common.waterHeight(rows: rows)
    }

    /// Position of the top of the water from the top of the screen
    func topOfWaterPosition(forRows rows: CGFloat) -> CGFloat {
        common.topOfWaterPosition(rows: rows) - common.toggleHeight
    }
}

struct TitrationScreen_Previews: PreviewProvider {
    static var previews: some View {
        TitrationScreen(
            model: TitrationViewModel(
                namePersistence: InMemoryNamePersistence()
            )
        )
        .padding()
        .previewLayout(.iPhone8Landscape)
    }
}
