//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct ConcentrationBarChart: View {

    let initialA: CGFloat
    let initialTime: CGFloat
    let concentrationA: Equation?
    let concentrationB: Equation?

    let currentTime: CGFloat?

    let display: ReactionPairDisplay

    let settings: BarChartGeometry

    var body: some View {
        BarChart(
            data: barData,
            time: currentTime ?? initialTime,
            settings: settings
        )
    }

    private var barData: [BarChartData] {
        [barDataA] + [barDataB].compactMap { $0 }
    }

    private var barDataA: BarChartData {
        if let conA = concentrationA, currentTime != nil {
            return BarChartData(
                label: TextLine(display.reactant.name),
                equation: conA,
                color: display.reactant.color,
                accessibilityLabel: label(name: display.reactant.name),
                initialValue: .init(value: initialA, color: Styling.barChartEmpty)
            )
        }
        return BarChartData(
            label: TextLine(display.reactant.name),
            equation: ConstantEquation(value: initialA),
            color: display.reactant.color,
            accessibilityLabel: label(name: display.reactant.name)
        )
    }

    private var barDataB: BarChartData? {
        if let conB = concentrationB, currentTime != nil {
            return BarChartData(
                label: TextLine(display.product.name),
                equation: conB,
                color: display.product.color,
                accessibilityLabel: label(name: display.product.name)
            )
        }
        if currentTime == nil {
            return BarChartData(
                label: TextLine(display.product.name),
                equation: ConstantEquation(value: 0),
                color: display.product.color,
                accessibilityLabel: label(name: display.product.name)
            )
        }
        return nil
    }

    private func label(name: String) -> String {
        "Bar chart showing concentration of \(name) in molar"
    }
}

struct BarChartAxisShape_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ConcentrationBarChart(
                initialA: 1,
                initialTime: 0.1,
                concentrationA: equation,
                concentrationB: equation2,
                currentTime: nil,
                display: ReactionType.A.display,
                settings: BarChartGeometry(
                    chartWidth: 300,
                    minYValue: 0,
                    maxYValue: 1
                )
            )

            ConcentrationBarChart(
                initialA: 1,
                initialTime: 0.1,
                concentrationA: equation,
                concentrationB: equation2,
                currentTime: 1.5,
                display: ReactionType.A.display,
                settings: BarChartGeometry(
                    chartWidth: 300,
                    minYValue: 0,
                    maxYValue: 1
                )
            )
        }
    }

    private static var equation = ZeroOrderConcentration(
        t1: 1,
        c1: 1,
        t2: 2,
        c2: 0.2
    )

    private static var equation2 = ZeroOrderConcentration(
        t1: 1,
        c1: 0.2,
        t2: 2,
        c2: 1
    )
}
