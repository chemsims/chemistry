//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct SolubilityComponents {

    let equilibriumConstant: CGFloat
    let initialConcentration: SoluteValues<CGFloat>
    let startTime: CGFloat
    let equilibriumTime: CGFloat
    let equation: SolubleReactionEquation
    let previousEquation: SolubleReactionEquation?

    init(
        equilibriumConstant: CGFloat,
        initialConcentration: SoluteValues<CGFloat>,
        startTime: CGFloat,
        equilibriumTime: CGFloat,
        previousEquation: SolubleReactionEquation?
    ) {
        self.equilibriumConstant = equilibriumConstant
        self.initialConcentration = initialConcentration
        self.startTime = startTime
        self.equilibriumTime = equilibriumTime
        self.previousEquation = previousEquation
        self.equation = SolubleReactionEquation(
            initialConcentration: initialConcentration,
            equilibriumConstant: equilibriumConstant,
            startTime: startTime,
            equilibriumTime: equilibriumTime,
            previousEquation: previousEquation
        )
    }

    var quotient: SolubilityQuotientEquation {
        SolubilityQuotientEquation(concentration: equation.concentration)
    }

    var quotientDiscontinuity: CGFloat? {
        guard previousEquation != nil else {
            return nil
        }
        return startTime
    }

    var concentrationDiscontinuity: SoluteValues<CGFloat>? {
        guard previousEquation != nil else {
            return nil
        }
        return .constant(startTime)
    }
}
