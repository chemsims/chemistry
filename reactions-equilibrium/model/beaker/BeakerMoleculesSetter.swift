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
            increasingElements: GridElementPair(
                first: element([], reactionEquation.productC),
                second: element([], reactionEquation.productD)
            ),
            decreasingElements: GridElementPair(
                first: element(moleculesA, reactionEquation.reactantA),
                second: element(moleculesB, reactionEquation.reactantB)
            ),
            grid: shuffledCoords
        )
    }

    var moleculesA: FractionedCoordinates {
        FractionedCoordinates(
            coordinates: balancer?.decreasingBalanced.first.coords ?? underlyingAMolecules,
            fractionToDraw: fractionToDraw(for: balancer?.decreasingBalanced.first)
        )
    }

    var moleculesB: FractionedCoordinates {
        FractionedCoordinates(
            coordinates:  balancer?.decreasingBalanced.second.coords ?? underlyingAMolecules,
            fractionToDraw: fractionToDraw(for: balancer?.decreasingBalanced.second)
        )
    }

    var cMolecules: [GridCoordinate] {
        balancer?.increasingBalanced.first.coords ?? []
    }

    var dMolecules: [GridCoordinate] {
        balancer?.increasingBalanced.second.coords ?? []
    }

    var cFractionToDraw: Equation {
        fractionToDraw(for: balancer?.increasingBalanced.first)
    }

    var dFractionToDraw: Equation {
        fractionToDraw(for: balancer?.increasingBalanced.second)
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
            increasingElements: GridElementPair(
                first: element(originalA, reverseReaction.reactantA),
                second: element(originalB, reverseReaction.reactantB)
            ),
            decreasingElements: GridElementPair(
                first: element(cMolecules, reverseReaction.productC),
                second: element(dMolecules, reverseReaction.productD)
            ),
            grid: forwardBeaker.shuffledCoords
        )
    }

    var aMolecules: FractionedCoordinates {
        FractionedCoordinates(
            coordinates: balancer?.increasingBalanced.first.coords ?? originalAMolecules,
            fractionToDraw: fraction(for: balancer?.increasingBalanced.first)
        )
    }

    var bMolecules: FractionedCoordinates {
        FractionedCoordinates(
            coordinates: balancer?.increasingBalanced.second.coords ?? originalBMolecules,
            fractionToDraw: fraction(for: balancer?.increasingBalanced.second)
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
