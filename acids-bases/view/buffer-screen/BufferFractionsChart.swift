//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct BufferFractionsChart: View {

    let layout: BufferScreenLayout
    let phase: BufferScreenViewModel.Phase
    @ObservedObject var saltModel: BufferSaltComponents
    @ObservedObject var strongModel: BufferStrongSubstanceComponents

    var body: some View {
        TimeChartView(
            data: [
                TimeChartDataLine(
                    equation: substanceEquation,
                    headColor: .blue,
                    haloColor: .red,
                    headRadius: layout.common.chartHeadRadius
                ),
                TimeChartDataLine(
                    equation: secondaryIonEquation,
                    headColor: .purple,
                    haloColor: .black,
                    headRadius: layout.common.chartHeadRadius
                )
            ],
            initialTime: minPh,
            currentTime: .constant(currentPh),
            finalTime: maxPh,
            canSetCurrentTime: false,
            settings: TimeChartLayoutSettings(
                xAxis: xAxis,
                yAxis: yAxis,
                haloRadius: layout.common.haloRadius,
                lineWidth: 0.4
            ),
            axisSettings: layout.common.chartAxis
        )
        .frame(square: layout.common.chartSize)
        .padding(.bottom, layout.common.barChartSettings.totalAxisHeight + layout.common.barChartSettings.chartToAxisSpacing)
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
        0.9 * helper.minValue
    }

    private var maxPh: CGFloat {
        1.1 * helper.maxValue
    }

    private var xAxis: AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: 0.1 * chartSize,
            maxValuePosition: 0.9 * chartSize,
            minValue: 0.9 * minPh,
            maxValue: 1.1 * maxPh
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
