//
// Reactions App
//
  

import CoreGraphics

fileprivate let settings = ReactionSettings.Input.self
fileprivate let minC = ReactionSettings.Input.minC
fileprivate let maxC = ReactionSettings.Input.maxC
fileprivate let maxT = ReactionSettings.Input.maxT

protocol ReactionInputLimits {
    var c1Limits: InputLimits { get }
    var c2Limits: InputLimits { get }
    var t1Limits: InputLimits { get }
    var t2Limits: InputLimits { get }
}

struct ReactionInputLimitsAllProperties: ReactionInputLimits {

    let cRange: InputRange
    let tRange: InputRange
    let c1: CGFloat
    let t1: CGFloat
    let hasT1Input: Bool

    var c1Limits: InputLimits {
        InputLimits(
            min: cRange.min,
            max: cRange.max,
            smallerOtherValue: cRange.min + cRange.minInputRange,
            largerOtherValue: nil
        )
    }

    var c2Limits: InputLimits {
        InputLimits(
            min: cRange.min,
            max: cRange.max,
            smallerOtherValue: nil,
            largerOtherValue: c1
        )
    }

    var t1Limits: InputLimits {
        InputLimits(
            min: tRange.min,
            max: tRange.max,
            smallerOtherValue: nil,
            largerOtherValue: tRange.max - tRange.minInputRange
        )
    }

    var t2Limits: InputLimits {
        InputLimits(
            min: tRange.min,
            max: tRange.max,
            smallerOtherValue: hasT1Input ? t1 : nil,
            largerOtherValue: nil
        )
    }
}

struct ReactionInputLimitsWithoutC2: ReactionInputLimits {
    let cRange: InputRange
    let tRange: InputRange
    let t1: CGFloat
    let c1: CGFloat
    let concentration: ConcentrationEquation

    var c1Limits: InputLimits {
        let minC2 = cRange.min
        let minT2 = t1 + tRange.valueSpacing + tRange.minInputRange
        let eq = concentration.shiftWith(c: minC2, t: minT2)
        let minC1 = eq.getConcentration(at: t1)
        return InputLimits(
            min: max(minC1, cRange.min),
            max: cRange.max,
            smallerOtherValue: cRange.min + cRange.minInputRange,
            largerOtherValue: nil
        )
    }

    var t1Limits: InputLimits {
        let shifted = concentration.shiftWith(c: cRange.max, t: tRange.max)
        let t1AtShiftedEq = shifted.time(for: c1) ?? tRange.max

        let withLowerBound = max(t1AtShiftedEq, tRange.max - tRange.minInputRange)
        let withUpperBound = min(withLowerBound, tRange.max)

        return InputLimits(
            min: tRange.min,
            max: withUpperBound,
            smallerOtherValue: nil,
            largerOtherValue: tRange.max - tRange.minInputRange
        )
    }

    var c2Limits: InputLimits {
        c1Limits
    }

    var t2Limits: InputLimits {
        let timeAtMinC = concentration.time(for: cRange.min)
        return InputLimits(
            min: tRange.min,
            max: min(timeAtMinC ?? tRange.max, tRange.max),
            smallerOtherValue: t1,
            largerOtherValue: nil
        )
    }
}

struct ReactionInputLimitsWithoutT2: ReactionInputLimits {
    let cRange: InputRange
    let tRange: InputRange
    let t1: CGFloat
    let c1: CGFloat
    let concentration: ConcentrationEquation

    var c1Limits: InputLimits {
        InputLimits(
            min: max(nonLinearC1, cRange.min),
            max: cRange.max,
            smallerOtherValue: cRange.min + cRange.minInputRange,
            largerOtherValue: nil
        )
    }

    /// We need to find a C1, such that we have the minimum change in c, at t2.
    /// This currently requires solving the equations non-linearly since the equations themselves depend on C1
    private var nonLinearC1: CGFloat {
        var c = concentration
        var minC = c.getConcentration(at: tRange.max)

        for _ in 0...50 {
            let minInput = minC + cRange.minInputRange + cRange.valueSpacing
            c = c.shiftWith(c: minInput, t: t1)
            let newMinC = c.getConcentration(at: tRange.max)
            minC = newMinC
        }

        return c.getConcentration(at: t1)
    }

    var c2Limits: InputLimits {
        let cAtMaxT2 = concentration.getConcentration(at: tRange.max)
        return InputLimits(
            min: max(cAtMaxT2, cRange.min),
            max: cRange.max,
            smallerOtherValue: nil,
            largerOtherValue: c1
        )
    }

    var t1Limits: InputLimits {
        let minC2Input = c1 - cRange.valueSpacing - cRange.minInputRange
        let eq = concentration.shiftWith(c: minC2Input, t: tRange.max)
        let maxT1 = eq.time(for: c1)
        return InputLimits(
            min: tRange.min,
            max: min(maxT1 ?? tRange.max, tRange.max),
            smallerOtherValue: nil,
            largerOtherValue: tRange.max - tRange.minInputRange
        )
    }

    var t2Limits: InputLimits {
        InputLimits(
            min: tRange.min,
            max: tRange.max,
            smallerOtherValue: t1,
            largerOtherValue: nil
        )
    }
}

