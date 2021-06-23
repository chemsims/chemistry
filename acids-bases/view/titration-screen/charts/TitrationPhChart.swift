//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct TitrationPhChart: View {

    let layout: TitrationScreenLayout
    let phase: TitrationViewModel.ReactionPhase
    @ObservedObject var strongSubstancePreEPModel: TitrationStrongSubstancePreEPModel
    @ObservedObject var strongSubstancePostEPModel: TitrationStrongSubstancePostEPModel

    var body: some View {
        TimeChartView(
            data: [
                TimeChartDataLine(
                    equation: phEquation,
                    headColor: .purple,
                    haloColor: nil,
                    headRadius: layout.common.chartHeadRadius
                )
            ],
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
            thresholdX: CGFloat(strongSubstancePreEPModel.maxTitrant),
            underlyingLeft: strongSubstancePreEPModel.pH,
            underlyingRight: RightHandPhEquation(
                underlying: strongSubstancePostEPModel.pH,
                equivalencePointSubstance: strongSubstancePreEPModel.maxTitrant
            )
        )
    }

    private var maxEquationInput: CGFloat {
        CGFloat(strongSubstancePreEPModel.maxTitrant) + CGFloat(strongSubstancePostEPModel.maxTitrant)
    }

    private var equationInput: CGFloat {
        if phase == .strongSubstancePreEP {
            return CGFloat(strongSubstancePreEPModel.titrantAdded)
        }
        return CGFloat(strongSubstancePostEPModel.titrantAdded + strongSubstancePreEPModel.maxTitrant)
    }
}

private struct RightHandPhEquation: Equation {
    let underlying: Equation
    let equivalencePointSubstance: Int

    func getY(at x: CGFloat) -> CGFloat {
        underlying.getY(at: x - CGFloat(equivalencePointSubstance))
    }
}
