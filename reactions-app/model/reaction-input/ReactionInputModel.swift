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

    mutating func copyFrom(_ other: ReactionInputModel) {
        inputC1 = other.inputC1
        inputC2 = other.inputC2
        inputT1 = other.inputT1
        inputT2 = other.inputT2
    }

    /// Returns a concentration at the mid-point between `inputC1`, and `minC2`
    var midConcentration: CGFloat {
        (inputC1 + minC2) / 2
    }

    /// Returns a time at the mid-point between `inputT1` and `maxT2`
    var midTime: CGFloat {
        (inputT1 + maxT2) / 2
    }
}

class ReactionInputAllProperties: ReactionInputModel {

    var inputC1: CGFloat = ReactionSettings.initialC {
        didSet {
            didSetC1?()
        }
    }
    var inputT1: CGFloat = ReactionSettings.initialT
    var inputC2: CGFloat?
    var inputT2: CGFloat?

    var didSetC1: (() -> Void)?

    var minC2: CGFloat {
        ReactionSettings.minCInput
    }
    var maxT2: CGFloat {
        ReactionSettings.maxTime
    }

    var concentrationA: ConcentrationEquation? {
        if let c2 = inputC2, let t2 = inputT2 {
            return ZeroOrderReaction(
                t1: inputT1,
                c1: inputC1,
                t2: t2,
                c2: c2
            )
        }
        return nil
    }
}

class ReactionInputWithoutC2: ReactionInputAllProperties {
    override var inputC2: CGFloat? {
        get { computedC2 }
        set { }
    }

    override var maxT2: CGFloat {
        let maxTimeForMinConcentration = concentrationA?.time(for: minC2) ?? super.maxT2
        let absoluteMaxTime = ReactionSettings.maxTInput
        return min(maxTimeForMinConcentration, absoluteMaxTime)
    }

    private var computedC2: CGFloat? {
        if let concentrationA = concentrationA, let t2 = inputT2 {
            return concentrationA.getConcentration(at: t2)
        }
        return nil
    }

    override var concentrationA: ConcentrationEquation? {
        return ZeroOrderReaction(c1: inputC1, t1: inputT1, rateConstant: 0.05)
    }
}

class ReactionInputWithoutT2: ReactionInputAllProperties {

    override var inputT2: CGFloat? {
        get { computedT2 }
        set { }
    }

    override var minC2: CGFloat {
        let minForMaxTime = concentrationA?.getConcentration(at: maxT2) ?? super.minC2
        let absoluteMin = ReactionSettings.minCInput
        return max(minForMaxTime, absoluteMin)
    }

    private var computedT2: CGFloat? {
        if let concentrationA = concentrationA, let c2 = inputC2 {
            return concentrationA.time(for: c2)
        }
        return nil
    }

    override var concentrationA: ConcentrationEquation? {
        return ZeroOrderReaction(c1: inputC1, t1: inputT1, rateConstant: 0.05)
    }
}
