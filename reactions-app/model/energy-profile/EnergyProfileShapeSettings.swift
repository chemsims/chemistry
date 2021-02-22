//
// Reactions App
//

import CoreGraphics

struct EnergyProfileShapeSettings {
    let peak: CGFloat
    let leftAsymptote: CGFloat
    let rightAsymptote: CGFloat

    /// The largest value of peak, after it is reduced by the catalyst
    let maxReducedPeak: CGFloat

    /// The smallest value of peak, after it is reduced by the catalyst
    let minReducedPeak: CGFloat

    /// Energy at the minimum temperature input
    let minTempEnergy: CGFloat

    /// Energy at the maximum temperature input
    let maxTempEnergy: CGFloat

    var isExoThermic: Bool {
        leftAsymptote > rightAsymptote
    }
}

extension ReactionOrder {
    var energyProfileShapeSettings: EnergyProfileShapeSettings {
        switch self {
        case .Zero:
            return EnergyProfileShapeSettings(
                peak: 0.9,
                leftAsymptote: 0.5,
                rightAsymptote: 0.2,
                maxReducedPeak: 0.8,
                minReducedPeak: 0.65,
                minTempEnergy: 0.6,
                maxTempEnergy: 0.95
            )
        case .First:
            return EnergyProfileShapeSettings(
                peak: 0.85,
                leftAsymptote: 0.2,
                rightAsymptote: 0.4,
                maxReducedPeak: 0.75,
                minReducedPeak: 0.6,
                minTempEnergy: 0.5,
                maxTempEnergy: 0.9
            )
        case .Second:
            return EnergyProfileShapeSettings(
                peak: 0.7,
                leftAsymptote: 0.35,
                rightAsymptote: 0.25,
                maxReducedPeak: 0.62,
                minReducedPeak: 0.5,
                minTempEnergy: 0.45,
                maxTempEnergy: 0.85
            )
        }
    }
}
