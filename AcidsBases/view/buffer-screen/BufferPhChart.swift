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
                .accessibility(hidden: true)

            VStack(spacing: layout.common.chartXAxisVSpacing) {
                plotArea

                Text("Moles added")
                    .frame(height: layout.common.chartXAxisHeight)
                    .accessibility(hidden: true)
            }
        }
        .font(.system(size: layout.common.chartLabelFontSize))
        .accessibilityElement(children: .contain)
        .accessibility(label: Text("Chart showing moles added vs pH"))
        .minimumScaleFactor(0.5)
    }

    private var plotArea: some View {
        ZStack {
            labels

            waterLine

            TimeChartView(
                data: data,
                initialTime: minSubstance,
                currentTime: .constant(
                    safeSubstanceAdded.getValue(
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

    private var waterLineColor: Color {
        .black
    }

    private var bufferLineColor: Color {
        .red
    }

    private var labels: some View {
        VStack(spacing: 0) {
            if pHIsDecreasing {
                Spacer()
            }
            labelRow(label: "Water", color: waterLineColor, accessibilityValue: waterAccessibilityValue)

            labelRow(label: "Buffer", color: bufferLineColor, accessibilityValue: bufferAccessibilityValue)
                .opacity(showBufferLine ? 1 : 0)

            if !pHIsDecreasing {
                Spacer()
            }
        }
        .padding(.leading, layout.pHLabelLeadingPadding)
        .padding(.vertical, layout.phLabelVerticalPadding)
    }

    private func labelRow(
        label: String,
        color: Color,
        accessibilityValue: String
    ) -> some View {
        HStack(spacing: layout.phLabelHSpacing) {
            Circle()
                .frame(square: layout.phLabelCircleSize)
                .foregroundColor(color)
            Text(label)
                .font(.system(size: layout.pHLabelFontSize))
            Spacer()
        }
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text("pH in \(label)"))
        .accessibility(value: Text(accessibilityValue))
    }

    private var waterAccessibilityValue: String {
        let direction = pHIsDecreasing ? "decreases" : "increases"
        return "linear line where pH \(direction) as moles are added"
    }

    private var bufferAccessibilityValue: String {
        let direction = pHIsDecreasing ? "decreases" : "increases"
        return "line which is mostly flat, until near the end of the x axis where is sharply \(direction)"
    }

    private var data: [TimeChartDataLine] {
        if showBufferLine {
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

    private var showBufferLine: Bool {
        model.phase == .addStrongSubstance
    }

    private var waterLine: some View {
        let startY = pHIsDecreasing ? 0.1 * chartSize : 0.9 * chartSize
        let endY = chartSize - startY
        return Path { p in
            p.move(to: CGPoint(x: minXValuePosition, y: startY))
            p.addLine(to: CGPoint(x: maxXValuePosition, y: endY))
        }
        .stroke(lineWidth: 0.4)
    }

    private var pHIsDecreasing: Bool {
        model.substance.type.isAcid
    }

    private var yAxis: LinearAxis<CGFloat> {
        let minPh = initialPh == finalPh ? initialPh - 1 : min(initialPh, finalPh)
        let maxPh = initialPh == finalPh ? initialPh + 1 : max(initialPh, finalPh)
        let maxValuePosition = 0.5 * (chartSize - deltaPhSize)
        let minValuePosition = maxValuePosition + deltaPhSize
        return LinearAxis(
            minValuePosition: minValuePosition,
            maxValuePosition: maxValuePosition,
            minValue: minPh,
            maxValue: maxPh
        )
    }

    private var xAxis: LinearAxis<CGFloat> {
        LinearAxis(
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
        strongModel.pH.getValue(at: 0)
    }

    private var finalPh: CGFloat {
        strongModel.pH.getValue(at: CGFloat(strongModel.maxSubstance))
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

private extension BufferScreenLayout {
    var phLabelCircleSize: CGFloat {
        0.06 * common.chartSize
    }

    var phLabelHSpacing: CGFloat {
        0.3 * phLabelCircleSize
    }

    var pHLabelFontSize: CGFloat {
        1.1 * phLabelCircleSize
    }

    var pHLabelSpacing: CGFloat {
        0.2 * phLabelCircleSize
    }

    var pHLabelLeadingPadding: CGFloat {
        1.5 * common.chartAxis.tickSize
    }

    var phLabelVerticalPadding: CGFloat {
        1.5 * common.chartAxis.tickSize
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
                            substancePersistence: InMemoryAcidOrBasePersistence(),
                            namePersistence: InMemoryNamePersistence.shared
                        ),
                        strongModel: BufferScreenViewModel(
                            substancePersistence: InMemoryAcidOrBasePersistence(),
                            namePersistence: InMemoryNamePersistence.shared
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
