//
// Reactions App
//
  

import CoreGraphics

protocol ReactionInputModel {
    var inputC1: CGFloat { get set }
    var inputC2: CGFloat? { get set }
    var inputT1: CGFloat { get set }
    var inputT2: CGFloat? { get set }

    var didSetC1: (() -> Void)? { get set }

    var minC2: CGFloat { get }
    var maxT2: CGFloat { get }

    var concentrationA: ConcentrationEquation? { get }

    var rateConstant: CGFloat? { get }

    var order: ReactionOrder { get }
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
    var midConcentration: CGFloat {
        (inputC1 + minC2) / 2
    }

    /// Returns a time at the mid-point between `inputT1` and `maxT2`
    var midTime: CGFloat {
        (inputT1 + maxT2) / 2
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

    var minC2: CGFloat {
        ReactionSettings.minCInput
    }

    var maxT2: CGFloat {
        ReactionSettings.maxTime
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
}

struct ReactionInputAllProperties: ReactionInputModel {

    init(order: ReactionOrder) {
        self.order = order
    }

    let order: ReactionOrder

    var inputC1: CGFloat = ReactionSettings.initialC {
        didSet {
            didSetC1?()
        }
    }
    var inputT1: CGFloat = ReactionSettings.initialT
    var inputC2: CGFloat?
    var inputT2: CGFloat?

    var didSetC1: (() -> Void)?

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
}

struct ReactionInputWithoutC2: ReactionInputModel {

    let order: ReactionOrder
    var didSetC1: (() -> Void)?

    var inputC1: CGFloat = ReactionSettings.initialC {
        didSet {
            didSetC1?()
        }
    }

    var inputT1: CGFloat = ReactionSettings.initialT

    var inputT2: CGFloat?

    var inputC2: CGFloat? {
        get { computedC2 }
        set { }
    }

    var maxT2: CGFloat {
        let absoluteMax = ReactionSettings.maxTInput
        let maxTimeForMinConcentration = concentrationA?.time(for: minC2) ?? absoluteMax
        return min(maxTimeForMinConcentration, absoluteMax)
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

}

struct ReactionInputWithoutT2: ReactionInputModel {

    let order: ReactionOrder

    var didSetC1: (() -> Void)?
    var inputC1: CGFloat = ReactionSettings.initialC {
        didSet {
            didSetC1?()
        }
    }

    var inputC2: CGFloat?

    var inputT1: CGFloat =  ReactionSettings.initialT

    var inputT2: CGFloat? {
        get { computedT2 }
        set { }
    }

    var minC2: CGFloat {
        let absoluteMin = ReactionSettings.minCInput
        let minForMaxTime = concentrationA?.getConcentration(at: maxT2) ?? absoluteMin
        return max(minForMaxTime, absoluteMin)
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
}
