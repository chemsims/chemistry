//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct BufferPhChart: View {

    let layout: BufferScreenLayout
    @ObservedObject var model: BufferScreenViewModel
    @ObservedObject var strongModel: BufferStrongSubstanceComponents

    var body: some View {
        HStack(spacing: layout.common.chartYAxisHSpacing) {
            Text("pH")
                .frame(height: layout.common.chartYAxisWidth)
                .rotationEffect(.degrees(-90))

            VStack(spacing: layout.common.chartXAxisVSpacing) {
                plotArea

                // TODO dynamic label
                Text("Moles added")
                    .frame(height: layout.common.chartXAxisHeight)
            }
        }
        .font(.system(size: layout.common.chartLabelFontSize))
    }

    private var plotArea: some View {
        ZStack {
            waterLine

            TimeChartView(
                data: data,
                initialTime: minSubstance,
                currentTime: .constant(
                    safeSubstanceAdded.getY(
                        at: CGFloat(strongModel.substanceAdded)
                    )
                ),
                finalTime: maxSubstance,
                canSetCurrentTime: false,
                settings: TimeChartLayoutSettings(
                    xAxis: xAxis,
                    yAxis: yAxis,
                    haloRadius: layout.common.haloRadius,
                    lineWidth: 0.4 // TODO
                ),
                axisSettings: layout.common.chartAxis
            )
        }
        .frame(square: chartSize)
    }

    private var data: [TimeChartDataLine] {
        if model.phase == .addStrongSubstance {
            return [
                TimeChartDataLine(
                    equation: strongModel.pH,
                    xEquation: Log10Equation(),
                    headColor: .red,
                    haloColor: nil,
                    headRadius: 3
                )
            ]
        }
        return []
    }

    private var waterLine: some View {
        let startY = model.substance.type.isAcid ? 0.1 * chartSize : 0.9 * chartSize
        let endY = chartSize - startY
        return Path { p in
            p.move(to: CGPoint(x: minXValuePosition, y: startY))
            p.addLine(to: CGPoint(x: maxXValuePosition, y: endY))
        }
        .stroke(lineWidth: 0.4)
    }

    private var yAxis: AxisPositionCalculations<CGFloat> {
        let minPh = initialPh == finalPh ? initialPh - 1 : min(initialPh, finalPh)
        let maxPh = initialPh == finalPh ? initialPh + 1 : max(initialPh, finalPh)
        let maxValuePosition = 0.5 * (chartSize - deltaPhSize)
        let minValuePosition = maxValuePosition + deltaPhSize
        return AxisPositionCalculations(
            minValuePosition: minValuePosition,
            maxValuePosition: maxValuePosition,
            minValue: minPh,
            maxValue: maxPh
        )
    }

    private var xAxis: AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: minXValuePosition,
            maxValuePosition: maxXValuePosition,
            minValue: log10(minSubstance),
            maxValue: log10(maxSubstance)
        )
    }

    private var minXValuePosition: CGFloat {
        0.1 * chartSize
    }

    private var maxXValuePosition: CGFloat {
        0.9 * chartSize
    }

    private var chartSize: CGFloat {
        layout.common.chartSize
    }

    private var initialPh: CGFloat {
        strongModel.pH.getY(at: 0)
    }

    private var finalPh: CGFloat {
        strongModel.pH.getY(at: CGFloat(strongModel.maxSubstance))
    }

    private var deltaPhSize: CGFloat {
        0.15 * chartSize
    }

    private var minSubstance: CGFloat {
        1
    }

    private var maxSubstance: CGFloat {
        CGFloat(strongModel.maxSubstance)
    }

    // We want to avoid the range 0 to 1 due to large log values, so we
    // instead start at 1. This way we can keep using a pH equation
    // in terms of substance added, rather then an equation
    // in terms of concentration (we would not need to do this
    // workaround if we had pH in terms of concentration)
    private var safeSubstanceAdded: Equation {
        LinearEquation(
            x1: 0,
            y1: 1,
            x2: maxSubstance,
            y2: maxSubstance
        )
    }
}

struct BufferPhChart_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    BufferPhChart(
                        layout: BufferScreenLayout(
                            common: AcidBasesScreenLayout(
                                geometry: geo,
                                verticalSizeClass: nil,
                                horizontalSizeClass: nil
                            )
                        ),
                        model: BufferScreenViewModel(
                            namePersistence: InMemoryNamePersistence()
                        ),
                        strongModel: BufferScreenViewModel(
                            namePersistence: InMemoryNamePersistence()
                        ).strongSubstanceModel
                    )
                    Spacer()
                }
                Spacer()
            }
        }
        .previewLayout(.iPhoneSELandscape)
    }
}
