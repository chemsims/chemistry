//
// Reactions App
//


import SwiftUI

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
        let beakerWidth = common.beakerWidth + common.sliderSettings.handleWidth

        let chartsWidth = common.chartTotalWidth
        let availableWidth = common.width - beakerWidth - chartsWidth
        let availableHeight = common.height - common.beakyBoxHeight

        return CGSize(
            width: 0.9 * availableWidth,
            height: 0.9 * availableHeight
        )
    }
}

struct TitrationScreen_Previews: PreviewProvider {
    static var previews: some View {
        TitrationScreen(model: TitrationViewModel())
            .padding()
            .previewLayout(.iPhone8Landscape)
    }
}
