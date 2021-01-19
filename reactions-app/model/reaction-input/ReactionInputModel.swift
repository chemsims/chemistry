//
// Reactions App
//
  

import CoreGraphics

protocol ReactionInputModel {
    var inputC1: CGFloat { get set }
    var inputC2: CGFloat? { get set }
    var inputT1: CGFloat { get set }
    var inputT2: CGFloat? { get set }

    var concentrationA: ConcentrationEquation? { get }

    var rateConstant: CGFloat? { get }

    var order: ReactionOrder { get }

    func limits(
        cAbsoluteSpacing: CGFloat,
        tAbsoluteSpacing: CGFloat
    ) -> ReactionInputLimits
}

fileprivate func cRange(spacing: CGFloat) -> InputRange {
    InputRange(
        min: ReactionSettings.Input.minC,
        max: ReactionSettings.Input.maxC,
        minInputRange: ReactionSettings.Input.minCRange,
        valueSpacing: spacing
    )
}

fileprivate func tRange(spacing: CGFloat) -> InputRange {
    InputRange(
        min: ReactionSettings.Input.minT1,
        max: ReactionSettings.Input.maxT,
        minInputRange: ReactionSettings.Input.minTRange,
        valueSpacing: ReactionSettings.Input.minTRange
    )
}

extension ReactionInputModel {
    var concentrationB: Equation? {
        concentrationA.map {
            ConcentrationBEquation(
                concentrationA: $0,
                initialAConcentration: inputC1
            )
        }
    }

    /// Returns a concentration at the mid-point between `inputC1`, and `minC2`
    var initC2: CGFloat {
        let minC = limits(cAbsoluteSpacing: 0, tAbsoluteSpacing: 0).c2Limits.min
        let dc = inputC1 - minC
        return inputC1 - ((2/3) * dc)
    }

    /// Returns a time at the mid-point between `inputT1` and `maxT2`
    var initT2: CGFloat {
        let maxT = limits(cAbsoluteSpacing: 0, tAbsoluteSpacing: 0).t2Limits.max
        let dt = maxT - inputT1
        return inputT1 + ((2 / 3) * dt)
    }

    var rateAtT1: CGFloat? {
        concentrationA?.getRate(at: inputT1)
    }

    var rateAtT2: CGFloat? {
        inputT2.flatMap { t2 in concentrationA?.getRate(at: t2) }
    }

    var reactionInput: ReactionInput? {
        if let c2 = inputC2, let t2 = inputT2 {
            return ReactionInput(
                c1: inputC1,
                c2: c2,
                t1: inputT1,
                t2: t2
            )
        }
        return nil
    }

    var concentrationA: ConcentrationEquation? {
        rateConstant.map { k in
            switch (order) {
            case .Zero:
                return ZeroOrderConcentration(c1: inputC1, t1: inputT1, rateConstant: k)
            case .First:
                return FirstOrderConcentration(c1: inputC1, t1: inputT1, rateConstant: k)
            case .Second:
                return SecondOrderConcentration(c1: inputC1, t1: inputT1, rateConstant: k)
            }
        }
    }

    fileprivate func allValuesInput(
        cSpacing: CGFloat,
        tSpacing: CGFloat
    ) -> ReactionInputLimits {
        ReactionInputLimitsAllProperties(
            cRange: cRange(spacing: cSpacing),
            tRange: getTRangeForOrder(spacing: tSpacing),
            c1: inputC1,
            t1: inputT1,
            hasT1Input: order == .Zero
        )
    }

    fileprivate func getTRangeForOrder(spacing: CGFloat) -> InputRange {
        if (order == .Zero) {
            return tRange(spacing: spacing)
        }
        return InputRange(
            min: ReactionSettings.Input.minT2,
            max: ReactionSettings.Input.maxT,
            minInputRange: ReactionSettings.Input.minTRange,
            valueSpacing: spacing
        )
    }
}

struct ReactionInputAllProperties: ReactionInputModel {

    let order: ReactionOrder

    var inputC1: CGFloat = ReactionSettings.initialC
    var inputT1: CGFloat = ReactionSettings.initialT
    var inputC2: CGFloat?
    var inputT2: CGFloat?

    var rateConstant: CGFloat? {
        if let c2 = inputC2, let t2 = inputT2 {
            switch (order) {
            case .Zero:
                return ZeroOrderConcentration.getRate(t1: inputT1, c1: inputC1, t2: t2, c2: c2)
            case .First:
                return FirstOrderConcentration.rateConstant(c1: inputC1, c2: c2, t1: inputT1, t2: t2)
            case .Second:
                return SecondOrderConcentration.rateConstant(c1: inputC1, c2: c2, t1: inputT1, t2: t2)
            }
        }
        return nil
    }

    func limits(cAbsoluteSpacing: CGFloat, tAbsoluteSpacing: CGFloat) -> ReactionInputLimits {
        allValuesInput(cSpacing: cAbsoluteSpacing, tSpacing: tAbsoluteSpacing)
    }
}

struct ReactionInputWithoutC2: ReactionInputModel {

    let order: ReactionOrder

    var inputC1: CGFloat = ReactionSettings.initialC
    var inputT1: CGFloat = ReactionSettings.initialT
    var inputT2: CGFloat?
    var inputC2: CGFloat? {
        get { computedC2 }
        set { }
    }

    private var computedC2: CGFloat? {
        if let concentrationA = concentrationA, let t2 = inputT2 {
            return concentrationA.getConcentration(at: t2)
        }
        return nil
    }

    var rateConstant: CGFloat? {
        ReactionSettings.reactionBRateConstant
    }

    func limits(cAbsoluteSpacing: CGFloat, tAbsoluteSpacing: CGFloat) -> ReactionInputLimits {
        if let concentration = concentrationA {
            return ReactionInputLimitsWithoutC2(
                cRange: cRange(spacing: cAbsoluteSpacing),
                tRange: tRange(spacing: tAbsoluteSpacing),
                t1: inputT1,
                concentration: concentration
            )
        }
        return allValuesInput(cSpacing: cAbsoluteSpacing, tSpacing: tAbsoluteSpacing)
    }
}

struct ReactionInputWithoutT2: ReactionInputModel {

    let order: ReactionOrder

    var inputC1: CGFloat = ReactionSettings.initialC
    var inputC2: CGFloat?
    var inputT1: CGFloat =  ReactionSettings.initialT
    var inputT2: CGFloat? {
        get { computedT2 }
        set { }
    }

    var computedT2: CGFloat? {
        if let concentrationA = concentrationA, let c2 = inputC2 {
            return concentrationA.time(for: c2)
        }
        return nil
    }

    var rateConstant: CGFloat? {
        ReactionSettings.reactionCRateConstant
    }

    func limits(
        cAbsoluteSpacing: CGFloat,
        tAbsoluteSpacing: CGFloat
    ) -> ReactionInputLimits {
        if let concentration = concentrationA {
            return ReactionInputLimitsWithoutT2(
                cRange: cRange(spacing: cAbsoluteSpacing),
                tRange: tRange(spacing: tAbsoluteSpacing),
                c1: inputC1,
                concentration: concentration
            )
        }
        return allValuesInput(cSpacing: cAbsoluteSpacing, tSpacing: tAbsoluteSpacing)
    }

    private var upperC2Limit: CGFloat? {
        let cAtMaxT = concentrationA?.getConcentration(at: ReactionSettings.Input.maxT)
        return cAtMaxT.map { $0 + ReactionSettings.Input.minCRange }
    }
}
