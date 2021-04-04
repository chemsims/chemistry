//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct MultiConcentrationPlotData {
    let equation: Equation
    let color: Color
    let discontinuity: CGPoint?
    let legendValue: String
}

struct MultiConcentrationPlot: View {

    let values: [MultiConcentrationPlotData]
    let equilibriumTime: CGFloat

    let initialTime: CGFloat
    @Binding var currentTime: CGFloat
    let finalTime: CGFloat
    let canSetCurrentTime: Bool

    let showData: Bool
    let offset: CGFloat
    let minDragTime: CGFloat?

    let canSetIndex: Bool
    @Binding var activeIndex: Int?
    let yLabel: String

    let settings: ReactionEquilibriumChartsLayoutSettings

    var body: some View {
        HStack(spacing: settings.axisLabelGapFromAxis) {
            Text(yLabel)
                .font(.system(size: settings.axisLabelFontSize))
                .rotationEffect(.degrees(-90))
                .fixedSize()
                .frame(width: settings.yAxisWidthLabelWidth)
                .zIndex(1)

            VStack(spacing: settings.axisLabelGapFromAxis) {
                labelledChart
                Text("Time")
                    .font(.system(size: settings.axisLabelFontSize))
                    .frame(height: settings.xAxisLabelHeight)
            }
        }
    }

    private var labelledChart: some View {
        ZStack(alignment: .topLeading) {
            equilibriumHighlight
            chart
            legend
        }
        .frame(width: settings.size, height: settings.size)
    }

    private var equilibriumHighlight: some View {
        EquilibriumHighlight(
            equilibriumTime: equilibriumTime,
            chartSize: settings.size,
            xAxis: settings.layout.xAxis,
            offset: offset
        )
    }

    private var chart: some View {
        TimeChartView(
            data: !showData ? [] : allData,
            initialTime: initialTime,
            currentTime: $currentTime,
            finalTime: finalTime,
            canSetCurrentTime: canSetCurrentTime,
            settings: settings.layout,
            axisSettings: settings.axisShapeSettings,
            clipData: true,
            offset: offset,
            minDragTime: minDragTime,
            activeIndex: activeIndex
        )
    }

    private var allData: [TimeChartDataLine] {
        values.map { value in
            data(equation: value.equation, color: value.color, discontinuity: value.discontinuity)
        }
    }

    private func data(
        equation: Equation,
        color: Color,
        discontinuity: CGPoint?
    ) -> TimeChartDataLine {
        TimeChartDataLine(
            equation: equation,
            headColor: color,
            haloColor: color.opacity(0.3),
            headRadius: settings.headRadius,
            discontinuity: discontinuity
        )
    }
}

extension MultiConcentrationPlot {
    private var legend: some View {
        HStack(spacing: settings.legendSpacing) {
            ForEach(0..<values.count, id: \.self) { i in
                legendPill(name: values[i].legendValue, color: values[i].color, indexToActivate: i)
            }
        }
    }

    private func legendPill(
        name: String,
        color: Color,
        indexToActivate: Int
    ) -> some View {
        Button(action: {
            activeIndex = activeIndex == indexToActivate ? nil : indexToActivate
        }) {
            ZStack {
                Circle()
                    .foregroundColor(color)
                    .opacity(activeIndex.forAll({$0 == indexToActivate}) ? 1 : 0.3)
                Text(name)
                    .font(.system(size: settings.legendFontSize))
                    .foregroundColor(.white)
            }
            .padding(settings.legendPadding)
            .contentShape(Rectangle())
            .frame(
                width: settings.legendCircleSize + (2 * settings.legendPadding),
                height: settings.legendCircleSize + (2 * settings.legendPadding)
            )
        }
        .disabled(!canSetIndex)
    }
}

struct MultiConcentrationPlot_Previews: PreviewProvider {
    static var previews: some View {
        MultiConcentrationPlot(
            values: BalancedReactionEquation(
                coefficients: BalancedReactionCoefficients(
                    reactantA: 2,
                    reactantB: 2,
                    productC: 1,
                    productD: 4
                ),
                equilibriumConstant: 1,
                initialConcentrations: MoleculeValue(
                    reactantA: 0.4,
                    reactantB: 0.8,
                    productC: 0,
                    productD: 0
                ),
                startTime: 0,
                equilibriumTime: 15,
                previous: nil
            ).concentration.all.map {
                MultiConcentrationPlotData(
                    equation: $0,
                    color: .red,
                    discontinuity: nil,
                    legendValue: "A"
                )
            },
            equilibriumTime: 15,
            initialTime: 0,
            currentTime: .constant(10),
            finalTime: 20,
            canSetCurrentTime: false,
            showData: true,
            offset: 0,
            minDragTime: nil,
            canSetIndex: false,
            activeIndex: .constant(nil),
            yLabel: "Concentration",
            settings: ReactionEquilibriumChartsLayoutSettings(
                size: 300,
                maxYAxisValue: AqueousReactionSettings.ConcentrationInput.maxAxis
            )
        )
    }
}
