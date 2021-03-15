//
// Reactions App
//

import CoreGraphics
import ReactionsCore

struct BeakerMoleculesSetter {

    let totalMolecules: Int
    let underlyingAMolecules: [GridCoordinate]
    let underlyingBMolecules: [GridCoordinate]
    let reactionEquation: BalancedReactionEquations
    let shuffledCoords: [GridCoordinate]

    private let balancer: GridElementBalancer?

    init(
        shuffledCoords: [GridCoordinate],
        moleculesA: [GridCoordinate],
        moleculesB: [GridCoordinate],
        reactionEquation: BalancedReactionEquations
    ) {
        self.totalMolecules = shuffledCoords.count
        self.shuffledCoords = shuffledCoords
        self.underlyingAMolecules = moleculesA
        self.underlyingBMolecules = moleculesB
        self.reactionEquation = reactionEquation

        func count(_ equation: Equation) -> Int {
            GridMoleculesUtil.gridCount(for: equation.getY(at: reactionEquation.convergenceTime), gridSize: shuffledCoords.count)
        }
        func element(_ coords: [GridCoordinate], _ equation: Equation) -> GridElementToBalance {
            GridElementToBalance(initialCoords: coords, finalCount: count(equation))
        }
        self.balancer = GridElementBalancer(
            initialIncreasingA: element([], reactionEquation.productC),
            initialIncreasingB: element([], reactionEquation.productD),
            initialReducingC: element(moleculesA, reactionEquation.reactantA),
            initialReducingD: element(moleculesB, reactionEquation.reactantB),
            grid: shuffledCoords
        )
    }

    var moleculesA: FractionedCoordinates {
        FractionedCoordinates(
            coordinates: balancer?.balancedC.coords ?? underlyingAMolecules,
            fractionToDraw: fractionToDraw(for: balancer?.balancedC)
        )
    }

    var moleculesB: FractionedCoordinates {
        FractionedCoordinates(
            coordinates:  balancer?.balancedD.coords ?? underlyingAMolecules,
            fractionToDraw: fractionToDraw(for: balancer?.balancedD)
        )
    }

    var cMolecules: [GridCoordinate] {
        balancer?.balancedA.coords ?? []
    }

    var dMolecules: [GridCoordinate] {
        balancer?.balancedB.coords ?? []
    }

    var cFractionToDraw: Equation {
        fractionToDraw(for: balancer?.balancedA)
    }

    var dFractionToDraw: Equation {
        fractionToDraw(for: balancer?.balancedB)
    }

    private func fractionToDraw(
        for element: BalancedGridElement?
    ) -> Equation {
        if let element = element {
            return EquilibriumReactionEquation(
                t1: 0,
                c1: CGFloat(element.initialFraction),
                t2: CGFloat(reactionEquation.convergenceTime),
                c2: CGFloat(element.finalFraction)
            )
        }
        return ConstantEquation(value: 1)
    }
}

struct ReverseBeakerMoleculeSetter {

    let totalMolecules: Int
    let reaction: BalancedReactionEquations
    let startTime: CGFloat
    let cMolecules: [GridCoordinate]
    let dMolecules: [GridCoordinate]
    let originalAMolecules: [GridCoordinate]
    let originalBMolecules: [GridCoordinate]

    let balancer: GridElementBalancer?

    init(
        reverseReaction: BalancedReactionEquations,
        startTime: CGFloat,
        forwardBeaker: BeakerMoleculesSetter,
        cMolecules: [GridCoordinate],
        dMolecules: [GridCoordinate]
    ) {
        self.totalMolecules = forwardBeaker.totalMolecules
        self.reaction = reverseReaction
        self.startTime = startTime
        self.cMolecules = cMolecules
        self.dMolecules = dMolecules

        let originalA = Self.initialReactantGrid(
            forwardCoords: forwardBeaker.moleculesA,
            forwardMolecules: forwardBeaker
        )
        self.originalAMolecules = originalA

        let originalB = Self.initialReactantGrid(
            forwardCoords: forwardBeaker.moleculesB,
            forwardMolecules: forwardBeaker
        )
        self.originalBMolecules = originalB

        assert(Set(cMolecules).intersection(Set(originalB + originalA)).isEmpty)
        assert(Set(dMolecules).intersection(Set(originalB + originalA)).isEmpty)

        func count(_ equation: Equation) -> Int {
            GridMoleculesUtil.gridCount(
                for: equation.getY(at: reverseReaction.convergenceTime),
                gridSize: forwardBeaker.totalMolecules
            )
        }
        func element(_ coords: [GridCoordinate], _ equation: Equation) -> GridElementToBalance {
            GridElementToBalance(initialCoords: coords, finalCount: count(equation))
        }

        self.balancer = GridElementBalancer(
            initialIncreasingA: element(originalA, reverseReaction.reactantA),
            initialIncreasingB: element(originalB, reverseReaction.reactantB),
            initialReducingC: element(cMolecules, reverseReaction.productC),
            initialReducingD: element(dMolecules, reverseReaction.productD),
            grid: forwardBeaker.shuffledCoords
        )
    }

    var aMolecules: FractionedCoordinates {
        FractionedCoordinates(
            coordinates: balancer?.balancedA.coords ?? originalAMolecules,
            fractionToDraw: fraction(for: balancer?.balancedA)
        )
    }

    var bMolecules: FractionedCoordinates {
        FractionedCoordinates(
            coordinates: balancer?.balancedB.coords ?? originalBMolecules,
            fractionToDraw: fraction(for: balancer?.balancedB)
        )
    }

    private func fraction(for element: BalancedGridElement?) -> Equation {
        if let element = element {
            return EquilibriumReactionEquation(
                t1: startTime,
                c1: CGFloat(element.initialFraction),
                t2: reaction.convergenceTime,
                c2: CGFloat(element.finalFraction)
            )
        }
        return ConstantEquation(value: 1)
    }

    private static func initialReactantGrid(
        forwardCoords: FractionedCoordinates,
        forwardMolecules: BeakerMoleculesSetter
    ) -> [GridCoordinate] {
        let convergenceTime = forwardMolecules.reactionEquation.convergenceTime
        let convergedForwardCoords = forwardCoords.coords(at: convergenceTime)
        let products = forwardMolecules.cMolecules + forwardMolecules.dMolecules
        return convergedForwardCoords.filter { coord in
            !products.contains(coord)
        }
    }
}
