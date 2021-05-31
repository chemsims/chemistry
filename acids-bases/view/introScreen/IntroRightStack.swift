//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct IntroRightStack: View {

    @ObservedObject var model: IntroScreenViewModel
    let layout: IntroScreenLayout

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
           bottomRow
        }
        .frame(width: layout.common.rightColumnWidth)
    }

    private var bottomRow: some View {
        HStack(spacing: 0) {
            barChart
            Spacer()
            beaky
        }
    }

    private var barChart: some View {
        BarChart(
            data: model.components.barChart.all,
            time: model.components.fractionSubstanceAdded,
            settings: layout.common.barChartSettings
        )
    }

    private var beaky: some View {
        BeakyBox(
            statement: model.statement,
            next: model.next,
            back: model.back,
            nextIsDisabled: false,
            settings: layout.common.beakySettings
        )
    }
}

struct IntroRightStack_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                Spacer()
                IntroRightStack(
                    model: IntroScreenViewModel(),
                    layout: IntroScreenLayout(
                        common: AcidBasesScreenLayout(
                            geometry: geo,
                            verticalSizeClass: nil,
                            horizontalSizeClass: nil
                        )
                    )
                )
            }
            .padding(5)
        }
        .previewLayout(.iPhone8Landscape)
    }
}
