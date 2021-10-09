//
// Reactions App
//

import CoreGraphics
import ReactionsCore


/// # Input Limit Terms
/// We have several constraints to satisfy for known and unknown input limits. Each term has a
/// derivation below, and we can first define a few terms:
///
/// - K: Initial known reactant coords added.
/// - U: Initial unknown reactant coords added.
/// - G: The size of the grid.
/// - C: Coefficient of the unknown reactant.
/// - K2: Amount of known reactant left over after the initial reaction. This
///      is equal to `K - U/C`.
/// - P: Amount of product produced by the initial reaction. This is
///     equal to `U/C`.
/// - E: Amount of extra unknown reactant we need to add to consume all of `K2` in
///     the second reaction. This is equal to `C*K2`.
/// - K2_min: The minimum amount of K2 we configure.
/// - U_min: The minimum amount of U we configure.

struct KnownReactantPrepInputLimits {
    let unknownReactantCoeff: Int
    let grid: BeakerGrid
    let settings: PrecipitationComponents.Settings

    var min: Int {
        let minToConsume = Double(minUnknownToReact) / Double(unknownReactantCoeff)
        return minRemainingPostReaction + minToConsume.roundedInt()
    }

    var max: Int {
        Swift.min(
            maxForGridSizeWithMinUnknown,
            maxForExtraReactantWithFirstUMax,
            maxForExtraReactantWithSecondUMax
        )
    }

    /// We want to satisfy `K + U <= G`. To achieve the biggest `K`, we should use
    /// the smallest `U`. In this case we use the configured value of `U_min`.
    private var maxForGridSizeWithMinUnknown: Int {
        grid.size - minUnknownToReact
    }

    /// We have the condition:
    /// `K2 + E + P <= G`, which resolves to
    /// `K - U/C + C(K - U/C) + U/C <= G`
    /// `K + KC - U <= G`
    ///
    /// To achieve the biggest `K`, then we must also use the biggest `U`.
    /// There are 2 constraints for the maximum `U` value, and the one we
    /// use in this equation is `K - U/C >= K2_min`, or
    /// `U <= C(K - K2_min)`.
    ///
    /// Substituting this value gives us:
    /// `K <= (G + C*K2_min) / (1 + C)`
    private var maxForExtraReactantWithFirstUMax: Int {
        let denom = grid.size + (unknownReactantCoeff * minRemainingPostReaction)
        let numer = 1 + unknownReactantCoeff
        return denom / numer
    }

    /// See the derivation on the constraint `maxForGridSizeWithMinUnknownCoeff`.
    /// We have, `K + KC - U <= G`, and would like to substitute an expression
    /// for the maximum `U` value. There are 2 constraints for the maximum `U` value,
    /// and the other one is `K + U <= G`, or `U <= G - K`.
    ///
    /// Substituting this value gives us:
    /// `K <= 2G / (2 + C)`
    private var maxForExtraReactantWithSecondUMax: Int {
        let denom = 2 * grid.size
        let numer = 2 + unknownReactantCoeff
        return denom / numer
    }

    private var minRemainingPostReaction: Int {
        grid.count(concentration: settings.minConcentrationOfKnownReactantPostFirstReaction)
    }

    private var minUnknownToReact: Int {
        grid.count(concentration: settings.minConcentrationOfUnknownReactantToReact)
    }
}

struct UnknownReactantPrepInputLimits {

    let unknownReactantCoeff: Int
    let knownReactantCount: Int
    let grid: BeakerGrid
    let settings: PrecipitationComponents.Settings

    var min: Int {
        Swift.max(minForConfiguration, minForExcessReactant)
    }

    var max: Int {
        Swift.min(maxForInitialGridSize, maxForMinimumKnownReactantToRemain)
    }

    private var minForConfiguration: Int {
        grid.count(concentration: settings.minConcentrationOfUnknownReactantToReact)
    }

    /// We have the constraint `K2 + E + P <= G`, which is:
    /// `K - U/C + C(K - U/C) + U/C <= G`,
    /// `K(1 + C) - U <= G`. So,
    /// `U >= K(1 + C) - G`
    private var minForExcessReactant: Int {
        knownReactantCount * (1 + unknownReactantCoeff) - grid.size
    }

    private var maxForInitialGridSize: Int {
        grid.size - knownReactantCount
    }

    private var maxForMinimumKnownReactantToRemain: Int {
        let maxToConsume = knownReactantCount - minKnownPostReaction
        return unknownReactantCoeff * maxToConsume
    }

    private var minKnownPostReaction: Int {
        grid.count(concentration: settings.minConcentrationOfKnownReactantPostFirstReaction)
    }

}
