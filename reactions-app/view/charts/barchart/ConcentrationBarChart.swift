//
// Reactions App
//
  

import SwiftUI

struct ConcentrationBarChart: View {

    let initialA: CGFloat
    let initialTime: CGFloat
    let concentrationA: Equation?
    let concentrationB: Equation?

    let currentTime: CGFloat?

    let display: ReactionPairDisplay

    let settings: BarChartGeometrySettings

    var body: some View {
        VStack {
            ZStack {
                BarChartMinorAxisShape(ticks: settings.ticks)
                    .stroke(lineWidth: 0.3)
                BarChartAxisShape(ticks: settings.ticks, tickSize: settings.yAxisTickSize)
                    .stroke(lineWidth: 1.4)

                barA
                    .accessibility(label: Text(label(name: display.reactant.name)))
                    .modifier(
                        valueModifier(
                            equation: concentrationA,
                            defaultValue: initialA
                        )
                    )

                barB
                    .accessibility(label: Text(label(name: display.product.name)))
                    .modifier(
                        valueModifier(
                            equation: concentrationB,
                            defaultValue: 0
                        )
                    )
            }
            .frame(width: settings.chartWidth, height: settings.chartWidth)
            ZStack {
                drawLabel(molecule: display.reactant, barX: settings.barACenterX)
                drawLabel(molecule: display.product, barX: settings.barBCenterX)
            }
            .accessibility(hidden: true)
        }
    }

    private func label(name: String) -> String {
        "Bar chart showing concentration of \(name) in molar"
    }

    private func valueModifier(
        equation: Equation?,
        defaultValue: CGFloat
    ) -> some ViewModifier {
        AccessibleValueModifier(
            x: currentTime ?? initialTime,
            format: { time in
                var concentration = defaultValue
                if let eq = equation {
                    concentration = eq.getY(at: time)
                }
                return concentration.str(decimals: 2)
            }
        )
    }



    private var barA: some View {
        return ZStack {
            drawBar(
                concentration: ConstantEquation(value: initialA),
                currentTime: 0,
                barCenterX: settings.barACenterX
            ).foregroundColor(currentTime == nil ? display.reactant.color : Styling.barChartEmpty)

            if (currentTime != nil && concentrationA != nil) {
                drawBar(
                    concentration: concentrationA!,
                    currentTime: currentTime!,
                    barCenterX: settings.barACenterX
                ).foregroundColor(display.reactant.color)
            }
        }
    }

    private var barB: some View {
        ZStack {
            if (currentTime == nil) {
                drawBar(
                    concentration: ConstantEquation(value: 0),
                    currentTime: 0,
                    barCenterX: settings.barBCenterX
                )
            }
            if (currentTime != nil && concentrationB != nil) {
                drawBar(
                    concentration: concentrationB!,
                    currentTime: currentTime!,
                    barCenterX: settings.barBCenterX
                )
            }
        }.foregroundColor(display.product.color)
    }

    private func drawBar(
        concentration: Equation,
        currentTime: CGFloat,
        barCenterX: CGFloat
    ) -> some View {
        return BarChartBarShape(
            settings: settings,
            concentrationEquation: concentration,
            barCenterX: barCenterX,
            currentTime: currentTime
        )
    }

    private func drawLabel(
        molecule: ReactionMoleculeDisplay,
        barX: CGFloat
    ) -> some View {
        VStack {
            Circle()
                .frame(width: settings.labelDiameter, height: settings.labelDiameter)
                .foregroundColor(molecule.color)

            Text(molecule.name)
                .font(.system(size: settings.labelFontSize))
        }.offset(x: barX - (settings.chartWidth / 2))
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
                settings: BarChartGeometrySettings(
                    chartWidth: 300,
                    maxConcentration: 1,
                    minConcentration: 0
                )
            )

            ConcentrationBarChart(
                initialA: 1,
                initialTime: 0.1,
                concentrationA: equation,
                concentrationB: equation2,
                currentTime: 1.5,
                display: ReactionType.A.display,
                settings: BarChartGeometrySettings(
                    chartWidth: 300,
                    maxConcentration: 1,
                    minConcentration: 0
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
