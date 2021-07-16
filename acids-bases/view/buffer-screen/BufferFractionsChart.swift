//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct BufferFractionsChart: View {

    let layout: BufferScreenLayout
    let phase: BufferScreenViewModel.Phase
    @ObservedObject var model: BufferScreenViewModel
    @ObservedObject var saltModel: BufferSaltComponents
    @ObservedObject var strongModel: BufferStrongSubstanceComponents

    var body: some View {
        VStack(spacing: layout.common.chartXAxisVSpacing) {
            HStack(spacing: layout.common.chartYAxisHSpacing) {
                yAxisView

                plotArea
                    .frame(square: layout.common.chartSize)
            }
            .frame(height: layout.common.chartSize)

            xAxisView
        }
        .padding(.bottom, bottomPadding)
    }

    private var bottomPadding: CGFloat {
        let barChartHeight = layout.common.barChartSettings.totalAxisHeight + layout.common.barChartSettings.chartToAxisSpacing
        let xAxisHeight = layout.common.chartXAxisHeight + layout.common.chartXAxisVSpacing
        return max(0, barChartHeight - xAxisHeight)
    }

    private var yAxisView: some View {
        VStack {
            Text("1")

            Spacer()

            Text("Fraction of species")
                .lineLimit(1)
                .frame(
                    width: 0.6 * layout.common.chartSize,
                    height: layout.common.chartYAxisWidth
                )
                .fixedSize()
                .rotationEffect(.degrees(-90))
                .frame(width: layout.common.chartYAxisWidth)

            Spacer()

            Text("0")
        }
        .font(.system(size: 0.6 * layout.common.chartLabelFontSize))
        .minimumScaleFactor(0.5)
    }

    private var xAxisView: some View {
        Text("pH")
            .font(.system(size: layout.common.chartLabelFontSize))
            .minimumScaleFactor(0.5)
            .frame(
                width: layout.common.chartSize,
                height: layout.common.chartXAxisHeight
            )
    }

    private var plotArea: some View {
        ZStack {
            annotations
            chart
        }
    }

    private var annotations: some View {
        ZStack {
            bufferRegion
            pkaLine
        }
    }

    private var bufferRegion: some View {
        let maxP = xAxis.getPosition(at: midPh + 1)
        let minP = xAxis.getPosition(at: midPh - 1)

        return Rectangle()
            .frame(width: maxP - minP)
            .position(x: xAxis.getPosition(at: midPh), y: layout.common.chartSize / 2)
            .foregroundColor(RGB.gray(base: 230).color)
            .opacity(0.3)
    }

    private var pkaLine: some View {
        Path { p in
            p.addLines([
                .init(x: xAxis.getPosition(at: midPh), y: 0),
                .init(x: xAxis.getPosition(at: midPh), y: layout.common.chartSize)
            ])
        }
        .stroke(style: layout.common.chartDashedLineStyle)
        .foregroundColor(.orangeAccent)
    }

    private var chart: some View {
        TimeChartView(
            data: [
                TimeChartDataLine(
                    equation: substanceEquation,
                    headColor: saltModel.substance.color(ofPart: .substance),
                    haloColor: nil,
                    headRadius: layout.common.chartHeadRadius
                ),
                TimeChartDataLine(
                    equation: secondaryIonEquation,
                    headColor: saltModel.substance.color(ofPart: .secondaryIon),
                    haloColor: nil,
                    headRadius: layout.common.chartHeadRadius
                )
            ],
            initialTime: initialChartPh,
            currentTime: .constant(currentPh),
            finalTime: finalChartPh,
            canSetCurrentTime: false,
            settings: TimeChartLayoutSettings(
                xAxis: xAxis,
                yAxis: yAxis,
                haloRadius: layout.common.haloRadius,
                lineWidth: 0.4
            ),
            axisSettings: layout.common.chartAxis
        )
    }

    private var initialChartPh: CGFloat {
        if saltModel.substance.type.isAcid {
            return minPh
        }
        return maxPh
    }

    private var finalChartPh: CGFloat {
        if saltModel.substance.type.isAcid {
            return maxPh
        }
        return minPh
    }

    private var currentPh: CGFloat {
        if phase == .addStrongSubstance {
            return strongModel.pH.getY(at: CGFloat(strongModel.substanceAdded))
        }
        return saltModel.pH.getY(at: CGFloat(saltModel.substanceAdded))
    }

    private var substanceEquation: Equation {
        if phase == .addStrongSubstance {
            return strongModel.substanceFractionInTermsOfPh
        }
        return saltModel.haFractionInTermsOfPH
    }

    private var secondaryIonEquation: Equation {
        if phase == .addStrongSubstance {
            return strongModel.secondaryIonFractionInTermsOfPh
        }
        return saltModel.aFractionInTermsOfPH
    }

    private var minPh: CGFloat {
        helper.minValue
    }

    private var maxPh: CGFloat {
        helper.maxValue
    }

    private var midPh: CGFloat {
        model.substance.pKA
    }

    private var xAxis: AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: 0.1 * chartSize,
            maxValuePosition: 0.9 * chartSize,
            minValue: minPh,
            maxValue: maxPh
        )
    }

    private var yAxis: AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: 0.9 * chartSize,
            maxValuePosition: 0.1 * chartSize,
            minValue: 0,
            maxValue: 1
        )
    }

    private var helper: FractionedChartAxisHelper {
        FractionedChartAxisHelper(
            initialPh: saltModel.initialPh,
            middlePh: saltModel.finalPH,
            minDelta: 1.5 // TODO - make this configurable somewhere
        )
    }

    private var chartSize: CGFloat {
        layout.common.chartSize
    }
}
