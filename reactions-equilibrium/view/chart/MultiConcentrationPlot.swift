//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct MultiConcentrationPlot: View {

    let equations: BalancedReactionEquations

    let initialTime: CGFloat
    @Binding var currentTime: CGFloat
    let finalTime: CGFloat
    let canSetCurrentTime: Bool

    let showData: Bool
    let offset: CGFloat
    let discontinuity: CGFloat?

    let settings: ReactionEquilibriumChartsLayoutSettings

    var body: some View {
        HStack(spacing: settings.axisLabelGapFromAxis) {
            Text("Concentration")
                .font(.system(size: settings.axisLabelFontSize))
                .rotationEffect(.degrees(-90))
                .fixedSize()
                .frame(width: settings.yAxisWidthLabelWidth)

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
            chart
            legend
        }
        .frame(width: settings.size, height: settings.size)
    }

    private var chart: some View {
        TimeChartView(
            data: !showData ? [] : [
                data(equation: equations.reactantA, color: .from(.aqMoleculeA)),
                data(equation: equations.reactantB, color: .from(.aqMoleculeB)),
                data(equation: equations.productC, color: .from(.aqMoleculeC)),
                data(equation: equations.productD, color: .from(.aqMoleculeD)),
            ],
            initialTime: initialTime,
            currentTime: $currentTime,
            finalTime: finalTime,
            canSetCurrentTime: canSetCurrentTime,
            settings: settings.layout,
            axisSettings: settings.axisShapeSettings,
            clipData: true,
            offset: offset,
            discontinuity: discontinuity
        )
    }

    private func data(equation: Equation, color: Color) -> TimeChartDataline {
        TimeChartDataline(
            equation: equation,
            headColor: color,
            haloColor: color.opacity(0.3),
            headRadius: settings.headRadius
        )
    }
}

extension MultiConcentrationPlot {
    private var legend: some View {
        HStack(spacing: settings.legendSpacing) {
            legendPill(name: "A", color: .from(.aqMoleculeA))
            legendPill(name: "B", color: .from(.aqMoleculeB))
            legendPill(name: "C", color: .from(.aqMoleculeC))
            legendPill(name: "D", color: .from(.aqMoleculeD))
        }
        .padding(settings.legendPadding)
    }

    private func legendPill(name: String, color: Color) -> some View {
        ZStack {
            Circle()
                .foregroundColor(color)
            Text(name)
                .font(.system(size: settings.legendFontSize))
                .foregroundColor(.white)
        }
        .frame(width: settings.legendCircleSize, height: settings.legendCircleSize)
    }
}

struct MultiConcentrationPlot_Previews: PreviewProvider {
    static var previews: some View {
        MultiConcentrationPlot(
            equations: BalancedReactionEquations(
                coefficients: BalancedReactionCoefficients(
                    reactantA: 2,
                    reactantB: 2,
                    productC: 1,
                    productD: 4
                ),
                a0: 0.4,
                b0: 0.8,
                convergenceTime: 15
            ),
            initialTime: 0,
            currentTime: .constant(10),
            finalTime: 20,
            canSetCurrentTime: false,
            showData: true,
            offset: 0,
            discontinuity: nil,
            settings: ReactionEquilibriumChartsLayoutSettings(
                size: 300,
                maxYAxisValue: AqueousReactionSettings.ConcentrationInput.maxAxis
            )
        )
    }
}
