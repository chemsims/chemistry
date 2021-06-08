//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct BufferChartStack: View {

    let layout: BufferScreenLayout
    @ObservedObject var model: BufferScreenViewModel

    var body: some View {
        Group {
            if model.phase == .addWeakSubstance {
                iceTable
            } else {
                BufferFractionCoords(model: model.phase2Model)
            }
        }
    }

    private var iceTable: some View {
        BufferICEStack(
            phase: model.phase,
            phase1Component: model.weakSubstanceModel,
            phase2Component: model.phase2Model
        )
    }
}

private struct BufferFractionCoords: View {

    @ObservedObject var model: BufferSaltComponents

    let size: CGFloat = 200

    var body: some View {
        TimeChartView(
            data: [
                TimeChartDataLine(
                    equation: model.haFractionInTermsOfPH,
                    headColor: .blue,
                    haloColor: .red,
                    headRadius: 2
                ),
                TimeChartDataLine(
                    equation: model.aFractionInTermsOfPH,
                    headColor: .purple,
                    haloColor: .black,
                    headRadius: 2
                )
            ],
            initialTime: 0,
            currentTime: .constant(model.ph.getY(at: CGFloat(model.substanceAdded))),
            finalTime: max(1, CGFloat(2 * model.finalPH)),
            canSetCurrentTime: false,
            settings: TimeChartLayoutSettings(
                xAxis: AxisPositionCalculations(
                    minValuePosition: 10,
                    maxValuePosition: 190,
                    minValue: 0,
                    maxValue: max(1, CGFloat(2 * model.finalPH))
                ),
                yAxis: AxisPositionCalculations(
                    minValuePosition: 190,
                    maxValuePosition: 10,
                    minValue: 0,
                    maxValue: 1
                ),
                haloRadius: 4,
                lineWidth: 1
            ),
            axisSettings: ChartAxisShapeSettings(chartSize: 200)
        )
        .frame(square: size)
    }
}

private struct BufferICEStack: View {

    let phase: BufferScreenViewModel.Phase
    @ObservedObject var phase1Component: BufferWeakSubstanceComponents
    @ObservedObject var phase2Component: BufferSaltComponents

    var body: some View {
        Group {
            if phase == .addWeakSubstance {
                ICETable(
                    columns: phase1Component.tableData,
                    x: phase1Component.progress
                )
            } else {
                ICETable(
                    columns: phase2Component.tableData,
                    x: CGFloat(phase2Component.substanceAdded)
                )
            }
        }
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
