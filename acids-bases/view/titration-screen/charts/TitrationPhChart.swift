//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct TitrationPhChart: View {

    let layout: TitrationScreenLayout
    let state: TitrationComponentState.State
    @ObservedObject var strongSubstancePreEPModel: TitrationStrongSubstancePreEPModel
    @ObservedObject var strongSubstancePostEPModel: TitrationStrongSubstancePostEPModel
    @ObservedObject var weakPreEPModel: TitrationWeakSubstancePreEPModel
    @ObservedObject var weakPostEPModel: TitrationWeakSubstancePostEPModel

    @ViewBuilder
    var body: some View {
        if state.substance.isStrong {
            GeneralTitrationPhChart(
                layout: layout,
                phase: state.phase,
                preEPReaction: strongSubstancePreEPModel,
                postEPReaction: strongSubstancePostEPModel
            )
        } else {
            GeneralTitrationPhChart(
                layout: layout,
                phase: state.phase,
                preEPReaction: weakPreEPModel,
                postEPReaction: weakPostEPModel
            )
        }
    }
}

private struct GeneralTitrationPhChart<PreEP: TitrationReactionModel, PostEP: TitrationReactionModel>: View {

    let layout: TitrationScreenLayout
    let phase: TitrationComponentState.Phase
    @ObservedObject var preEPReaction: PreEP
    @ObservedObject var postEPReaction: PostEP

    var body: some View {
        TimeChartView(
            data: data,
            initialTime: 0,
            currentTime: .constant(equationInput),
            finalTime: maxEquationInput,
            canSetCurrentTime: false,
            settings: .init(
                xAxis: xAxis,
                yAxis: yAxis,
                haloRadius: layout.common.haloRadius,
                lineWidth: 0.4 // TODO
            ),
            axisSettings: layout.common.chartAxis
        )
        .frame(square: layout.common.chartSize)
    }

    private var data: [TimeChartDataLine] {
        if phase == .preEP || phase == .postEP {
            return [
                TimeChartDataLine(
                    equation: phEquation,
                    headColor: .purple,
                    haloColor: nil,
                    headRadius: layout.common.chartHeadRadius
                )
            ]
        }
        return []
    }

    private var yAxis: AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: 0.9 * layout.common.chartSize,
            maxValuePosition: 0.1 * layout.common.chartSize,
            minValue: 0,
            maxValue: 14
        )
    }

    private var xAxis: AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: 0.1 * layout.common.chartSize,
            maxValuePosition: 0.9 * layout.common.chartSize,
            minValue: 0,
            maxValue: maxEquationInput
        )
    }

    private var phEquation: Equation {
        SwitchingEquation(
            thresholdX: CGFloat(preEPReaction.maxTitrant),
            underlyingLeft: preEPReaction.pH,
            underlyingRight: PostEquivalencePointPHEquation(
                underlying: postEPReaction.pH,
                equivalencePointTitrant: preEPReaction.maxTitrant
            )
        )
    }

    private var maxEquationInput: CGFloat {
        CGFloat(preEPReaction.maxTitrant) + CGFloat(postEPReaction.maxTitrant)
    }

    private var equationInput: CGFloat {
        if phase == .preEP {
            return CGFloat(preEPReaction.titrantAdded)
        }
        return CGFloat(postEPReaction.titrantAdded + preEPReaction.maxTitrant)
    }
}

private struct PostEquivalencePointPHEquation: Equation {
    let underlying: Equation

    /// Titrant added at the equivalence point
    let equivalencePointTitrant: Int

    func getY(at x: CGFloat) -> CGFloat {
        underlying.getY(at: x - CGFloat(equivalencePointTitrant))
    }
}
