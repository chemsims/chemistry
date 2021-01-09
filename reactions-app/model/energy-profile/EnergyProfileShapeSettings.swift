//
// Reactions App
//
  

import CoreGraphics

struct EnergyProfileShapeSettings {
    let peak: CGFloat
    let leftAsymptote: CGFloat
    let rightAsymptote: CGFloat
}

extension ReactionOrder {
    var energyProfileShapeSettings: EnergyProfileShapeSettings {
        switch (self) {
        case .Zero:
            return EnergyProfileShapeSettings(
                peak: 1,
                leftAsymptote: 0.5,
                rightAsymptote: 0.2
            )
        case .First:
            return EnergyProfileShapeSettings(
                peak: 0.9,
                leftAsymptote: 0.2,
                rightAsymptote: 0.5
            )
        case .Second:
            return EnergyProfileShapeSettings(
                peak: 0.8,
                leftAsymptote: 0.4,
                rightAsymptote: 0.3
            )
        }
    }
}
