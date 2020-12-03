//
// Reactions App
//
  

import SwiftUI

struct EnergyProfileRateChart: View {

    let settings: EnergyRateChartSettings
    let equation: ConcentrationEquation?
    let currentTempInverse: CGFloat?

    var body: some View {
        HStack {
            Text("ln(k)")
                .fixedSize()
            VStack {
                chart
                Text("1/T")
                    .fixedSize()
            }
        }
        .font(.system(size: settings.fontSize * 0.9))
        .lineLimit(1)
        .minimumScaleFactor(1)
    }

    private var chart: some View  {
        ZStack {
            if (equation != nil) {
                ConcentrationEquationShape(
                    equation: equation!,
                    yAxis: settings.yAxis,
                    xAxis: settings.xAxis,
                    initialTime: 1 / 600,
                    finalTime: 1 / 400,
                    minTime: nil,
                    maxTime: nil
                )
                .stroke()
                .foregroundColor(.orangeAccent)
            }

            if (equation != nil && currentTempInverse != nil) {
                ZStack {
                    Circle()
                        .frame(width: settings.chartHeadHaloSize, height: settings.chartHeadHaloSize)
                        .foregroundColor(Styling.primaryColorHalo)
                    Circle()
                        .frame(width: settings.chartHeadSize, height: settings.chartHeadHaloSize)
                        .foregroundColor(.orangeAccent)
                }
                .position(
                    x: settings.xAxis.getPosition(at: currentTempInverse!),
                    y: settings.yAxis.getPosition(at: equation!.getConcentration(at: currentTempInverse!))
                )
            }

            if (equation != nil) {
                annotation
            }

            ChartAxisShape(
                verticalTicks: settings.verticalTicks,
                horizontalTicks: settings.horizontalTicks,
                tickSize: settings.tickSize,
                gapToTop: settings.gapFromMaxTickToChart,
                gapToSide: settings.gapFromMaxTickToChart
            )
            .stroke()
        }.frame(width: settings.chartSize, height: settings.chartSize)
    }

    private var annotation: some View {
        VStack {
            Spacer()
            HStack {
                Text("Slope=-Ea/R")
                Spacer()
            }
        }
        .padding(.bottom, settings.chartSize * 0.1)
        .padding(.leading, settings.chartSize * 0.1)
        .font(.system(size: settings.fontSize * 0.8))
        .lineLimit(1)
    }
}

struct EnergyRateChartSettings {
    let chartSize: CGFloat
    init(chartSize: CGFloat) {
        self.chartSize = chartSize
        self.timeChartSettings = TimeChartGeometrySettings(chartSize: chartSize)
    }

    private let timeChartSettings: TimeChartGeometrySettings

    var verticalTicks: Int {
        timeChartSettings.verticalTicks
    }

    var horizontalTicks: Int {
        timeChartSettings.horizontalTicks
    }

    var tickSize: CGFloat {
        timeChartSettings.tickSize
    }

    var gapFromMaxTickToChart: CGFloat {
        timeChartSettings.gapFromMaxTickToChart
    }

    var chartHeadSize: CGFloat {
        timeChartSettings.chartHeadPrimarySize
    }

    var chartHeadHaloSize: CGFloat {
        timeChartSettings.chartHeadPrimaryHaloSize
    }

    var annotationMoleculeSize: CGFloat {
        chartSize * 0.05
    }

    var yAxis: AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: chartSize,
            maxValuePosition: 0,
            minValue: log(0.6),
            maxValue: log(8)
        )
    }

    var xAxis: AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: 0.1 * chartSize,
            maxValuePosition: 0.9 * chartSize,
            minValue: 1 / 600,
            maxValue: 1 / 400
        )
    }

    var fontSize: CGFloat {
        timeChartSettings.labelFontSize
    }

}

struct EnergyProfileRateChart_Previews: PreviewProvider {
    static var previews: some View {
        EnergyProfileRateChart(
            settings: EnergyRateChartSettings(chartSize: 250),
            equation: LinearConcentration(m: -350, t1: 1/400, c1: log(6)),
            currentTempInverse: 1 / 500
        )
    }
}
