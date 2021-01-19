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

    let inputC1: CGFloat
    let inputT1: CGFloat
    let hasT1Input: Bool

    var c1Limits: InputLimits {
        InputLimits(
            min: minC,
            max: maxC,
            smallerOtherValue: ReactionSettings.Input.minC2Input,
            largerOtherValue: nil
        )
    }

    var c2Limits: InputLimits {
        InputLimits(
            min: minC,
            max: maxC,
            smallerOtherValue: nil,
            largerOtherValue: inputC1
        )
    }

    var t1Limits: InputLimits {
        InputLimits(
            min: ReactionSettings.Input.minT1,
            max: ReactionSettings.Input.maxT,
            smallerOtherValue: nil,
            largerOtherValue: ReactionSettings.Input.minT2Input
        )
    }

    var t2Limits: InputLimits {
        InputLimits(
            min: hasT1Input ? 0 : ReactionSettings.Input.minT2,
            max: maxT,
            smallerOtherValue: hasT1Input ? inputT1 : nil,
            largerOtherValue: nil
        )
    }
}

struct ReactionInputLimitsWithoutC2: ReactionInputLimits {

    let inputT1: CGFloat
    let concentration: ConcentrationEquation?
    let tAbsoluteSpacing: CGFloat
    let underlying: ReactionInputLimitsAllProperties


    var c1Limits: InputLimits {
        let minT2Input = inputT1 + tAbsoluteSpacing + settings.minTRange
        let cAtMinT2 = concentration?.getConcentration(at: minT2Input)
        return InputLimits(
            min: cAtMinT2 ?? underlying.c1Limits.min,
            max: underlying.c1Limits.max,
            smallerOtherValue: underlying.c1Limits.smallerOtherValue,
            largerOtherValue: nil
        )
    }

    var c2Limits: InputLimits {
        underlying.c2Limits
    }

    var t1Limits: InputLimits {
        return InputLimits(
            min: underlying.t1Limits.min,
            max: underlying.t1Limits.max,
            smallerOtherValue: nil,
            largerOtherValue: t1LargerOtherValue
        )
    }

    var t2Limits: InputLimits {
        InputLimits(
            min: ReactionSettings.Input.minT1,
            max: maxT2,
            smallerOtherValue: inputT1,
            largerOtherValue: nil
        )
    }

    private var maxT2: CGFloat {
        let maxTimeForMinConcentration = concentration?.time(for: minC) ?? maxT
        return min(maxTimeForMinConcentration, maxT)
    }

    private var t1LargerOtherValue: CGFloat? {
        let timeForMinConcentration = concentration?.time(for: c2Limits.min)
        let t2MinInputOpt = timeForMinConcentration.map { $0 - settings.minTRange }
        let t2MinInput = t2MinInputOpt.map { min($0, settings.minT2Input) }
        return t2MinInput
    }


}

struct ReactionInputsLimitsWithoutT2: ReactionInputLimits {

    let concentration: ConcentrationEquation?
    let inputC1: CGFloat
    let cAbsoluteSpacing: CGFloat
    let underlying: ReactionInputLimitsAllProperties

    var c1Limits: InputLimits {
        InputLimits(
            min: minC,
            max: maxC,
            smallerOtherValue: upperC2Limit ?? ReactionSettings.Input.minC2Input,
            largerOtherValue: nil
        )
    }

    var c2Limits: InputLimits {
        InputLimits(
            min: minC2,
            max: maxC,
            smallerOtherValue: nil,
            largerOtherValue: inputC1
        )
    }

    var t1Limits: InputLimits {
        let lowerC1 = upperC2Limit.map { $0 + cAbsoluteSpacing }
        let time = lowerC1.flatMap { concentration?.time(for: $0) }
        let upperLimit = time ?? ReactionSettings.Input.minT2Input
        return InputLimits(
            min: ReactionSettings.Input.minT1,
            max: upperLimit,
            smallerOtherValue: nil,
            largerOtherValue: ReactionSettings.Input.minT2Input
        )
    }

    var t2Limits: InputLimits {
        underlying.t2Limits
    }

    private var minC2: CGFloat {
        let minForMaxTime = concentration?.getConcentration(at: maxT) ?? minC
        return max(minForMaxTime, minC)
    }

    private var upperC2Limit: CGFloat? {
        let cAtMaxT = concentration?.getConcentration(at: maxT)
        return cAtMaxT.map { $0 + ReactionSettings.Input.minCRange }
    }
}
