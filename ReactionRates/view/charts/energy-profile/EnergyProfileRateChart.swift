//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct EnergyProfileRateChart: View {

    let settings: EnergyRateChartSettings
    let equation: Equation?
    let currentTempInverse: CGFloat?
    let highlightChart: Bool

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
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text(label))
        .accessibility(value: Text(value))
    }

    private var label: String {
        let msg = "Chart showing inverse T vs natural log of K"
        let suffix = equation != nil ? ", with a straight line which has a slope of minus EA divide by R" : ""
        return "\(msg) \(suffix)"
    }

    private var value: String {
        if let invT = currentTempInverse, let equation = equation {
            let lnK = equation.getValue(at: invT)
            let regularT = (1 / invT).str(decimals: 0)
            return "Inverse T 1 divide by \(regularT), ln K \(lnK.str(decimals: 2))"
        }
        return "No data"
    }

    private var chart: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .opacity(highlightChart ? 1 : 0)

            if equation != nil {
                ChartLine(
                    equation: equation!,
                    yAxis: settings.yAxis,
                    xAxis: settings.xAxis,
                    startX: 1 / 600,
                    endX: 1 / 400
                )
                .stroke()
                .foregroundColor(.orangeAccent)
            }

            if equation != nil && currentTempInverse != nil {
                ZStack {
                    Circle()
                        .frame(
                            width: settings.chartHeadHaloSize * 2,
                            height: settings.chartHeadHaloSize * 2
                        )
                        .foregroundColor(Styling.primaryColorHalo)
                    Circle()
                        .frame(
                            width: settings.chartHeadSize * 2,
                            height: settings.chartHeadSize * 2
                        )
                        .foregroundColor(.orangeAccent)
                }
                .position(
                    x: settings.xAxis.getPosition(at: currentTempInverse!),
                    y: settings.yAxis.getPosition(at: equation!.getValue(at: currentTempInverse!))
                )
            }

            if equation != nil {
                annotation
            }

            ChartAxisShape(
                settings: settings.timeChartSettings.chartAxisShapeSettings
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
        self.timeChartSettings = ReactionRateChartLayoutSettings(chartSize: chartSize)
    }

    let timeChartSettings: ReactionRateChartLayoutSettings

    var chartHeadSize: CGFloat {
        timeChartSettings.chartHeadPrimarySize
    }

    var chartHeadHaloSize: CGFloat {
        timeChartSettings.chartHeadPrimaryHaloSize
    }

    var annotationMoleculeSize: CGFloat {
        chartSize * 0.05
    }

    var yAxis: LinearAxis<CGFloat> {
        LinearAxis(
            minValuePosition: chartSize,
            maxValuePosition: 0,
            minValue: log(0.6),
            maxValue: log(8)
        )
    }

    var xAxis: LinearAxis<CGFloat> {
        LinearAxis(
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
            equation: ZeroOrderConcentration(a0: 1, rateConstant: 0.1),
            currentTempInverse: 1 / 500,
            highlightChart: true
        )
    }
}
