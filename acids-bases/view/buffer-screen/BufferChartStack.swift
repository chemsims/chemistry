//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct BufferChartStack: View {

    let layout: BufferScreenLayout
    @ObservedObject var model: BufferScreenViewModel

    var body: some View {
        VStack(spacing: 0) {
            tableOrGraph
            Spacer()
            bottomCharts
        }
    }

    private var tableOrGraph: some View {
        BufferPHChartOrTable(
            layout: layout,
            model: model
        )
    }

    private var bottomCharts: some View {
        BufferBottomCharts(layout: layout, model: model)
            .padding(.leading, layout.common.chartYAxisWidth + layout.common.chartYAxisHSpacing)
    }
}

struct BufferChartStack_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            BufferChartStack(
                layout: BufferScreenLayout(
                    common: AcidBasesScreenLayout(
                        geometry: geo,
                        verticalSizeClass: nil,
                        horizontalSizeClass: nil
                    )
                ),
                model: BufferScreenViewModel()
            )
        }
        .padding()
        .previewLayout(.iPhone8Landscape)
    }
}
