//
// Reactions App
//
  

import CoreGraphics

struct EnergyProfileChartInput {
    let initialPeak: CGFloat
    let reducedPeak: CGFloat
    let leftAsymptote: CGFloat
    let rightAsymptote: CGFloat
    let currentEnergy: CGFloat

    var canReactToC: Bool {
        currentEnergy >= reducedPeak
    }
}

extension EnergyProfileChartInput {

    init(
        shape: EnergyProfileShapeSettings,
        temperature: CGFloat,
        catalyst: Catalyst?,
        minTemp: CGFloat = 400,
        maxTemp: CGFloat = 600
    ) {
        self.init(
            initialPeak: shape.peak,
            reducedPeak: catalyst.map {
                EnergyProfileChartInput.getReducedPeak(shape: shape, catalyst: $0)
            } ?? shape.peak,
            leftAsymptote: shape.leftAsymptote,
            rightAsymptote: shape.rightAsymptote,
            currentEnergy: EnergyProfileChartInput.getCurrentEnergy(
                shape: shape,
                temp: temperature,
                minTemp: minTemp,
                maxTemp: maxTemp
            )
        )
    }

    private static func getReducedPeak(shape: EnergyProfileShapeSettings, catalyst: Catalyst) -> CGFloat {
        switch (catalyst) {
        case .A: return shape.maxReducedPeak
        case .B: return (shape.minReducedPeak + shape.maxReducedPeak) / 2
        case .C: return shape.minReducedPeak
        }
    }

    private static func getCurrentEnergy(
        shape: EnergyProfileShapeSettings,
        temp: CGFloat,
        minTemp: CGFloat,
        maxTemp: CGFloat
    ) -> CGFloat {
        let equation = LinearEquation(
            x1: minTemp,
            y1: shape.minTempEnergy,
            x2: maxTemp,
            y2: shape.maxTempEnergy
        )
        return equation.getY(at: temp)
    }
}
