//
// Reactions App
//

import ReactionsCore
import CoreGraphics

struct GridMoleculesUtil {
    static func settingGridMoleculesConcentration(
        molecules: [GridCoordinate],
        concentration: CGFloat,
        avoiding: [GridCoordinate]
    ) -> [GridCoordinate] {
        let totalNum = equilibriumGridCount(for: concentration)
        let toAdd = totalNum - molecules.count

        if toAdd > 0 {
            return GridCoordinateList.addingRandomElementsTo(
                grid: molecules,
                count: toAdd,
                cols: EquilibriumGridSettings.cols,
                rows: EquilibriumGridSettings.rows,
                avoiding: avoiding
            )
        } else if toAdd < 0 {
            let toKeep = molecules.count - toAdd
            return Array(molecules.prefix(toKeep))
        }

        return molecules
    }

    static func equilibriumGridCount(for concentration: CGFloat) -> Int {
        (concentration * CGFloat(EquilibriumGridSettings.grid.count)).roundedInt()
    }
}

struct ForwardGridMolecules {

    private let shuffledEquilibriumGrid = EquilibriumGridSettings.grid.shuffled()

    func aGrid(reaction: BalancedReactionEquations) -> FractionedCoordinates {
        FractionedCoordinates(
            coordinates: underlyingAGrid,
            fractionToDraw: fractionAToDraw(reaction: reaction)
        )
    }

    func bGrid(reaction: BalancedReactionEquations) -> FractionedCoordinates {
        FractionedCoordinates(
            coordinates: underlyingBGrid,
            fractionToDraw: fractionBToDraw(reaction: reaction)
        )
    }

    func cGrid(reaction: BalancedReactionEquations) -> FractionedCoordinates {
        FractionedCoordinates(
            coordinates: underlyingCGrid(reaction: reaction),
            fractionToDraw: fractionCToDraw(reaction: reaction)
        )
    }

    func dGrid(reaction: BalancedReactionEquations) -> FractionedCoordinates {
        FractionedCoordinates(
            coordinates: underlyingDGrid(reaction: reaction),
            fractionToDraw: fractionDToDraw(reaction: reaction)
        )
    }

    private var underlyingAGrid: [GridCoordinate] = []
    private var underlyingBGrid: [GridCoordinate] = []

    private func underlyingCGrid(reaction: BalancedReactionEquations) -> [GridCoordinate] {
        let count = getProductCount(underlying: reaction.productC, convergenceTime: reaction.convergenceTime)
        return Array(shuffledEquilibriumGrid.prefix(count))
    }

    private func underlyingDGrid(reaction: BalancedReactionEquations) -> [GridCoordinate] {
        let count = getProductCount(underlying: reaction.productD, convergenceTime: reaction.convergenceTime)
        let cCount = underlyingCGrid(reaction: reaction).count
        let coords = shuffledEquilibriumGrid.dropFirst(cCount).prefix(count)
        return Array(coords)
    }

    private func getProductCount(underlying: Equation, convergenceTime: CGFloat) -> Int {
        let concentration = underlying.getY(at: convergenceTime)
        return GridMoleculesUtil.equilibriumGridCount(for: concentration)
    }

    mutating func setConcentration(of reactant: AqueousMoleculeReactant, concentration: CGFloat) {
        let newMolecules = GridMoleculesUtil.settingGridMoleculesConcentration(
            molecules: reactant == .A ? underlyingAGrid : underlyingBGrid,
            concentration: concentration,
            avoiding: reactant == .A ? underlyingBGrid : underlyingAGrid
        )
        if reactant == .A {
            underlyingAGrid = newMolecules
        } else {
            underlyingBGrid = newMolecules
        }
    }

    private func fractionAToDraw(reaction: BalancedReactionEquations) -> Equation {
        reactantEquation(underlying: reaction.reactantA)
    }

    private func fractionBToDraw(reaction: BalancedReactionEquations) -> Equation {
        reactantEquation(underlying: reaction.reactantB)
    }

    private func fractionCToDraw(reaction: BalancedReactionEquations) -> Equation {
        productEquation(underlying: reaction.productC, reaction: reaction)
    }

    private func fractionDToDraw(reaction: BalancedReactionEquations) -> Equation {
        productEquation(underlying: reaction.productD, reaction: reaction)
    }

    private func reactantEquation(underlying: Equation) -> Equation {
        ScaledEquation(
            targetY: 1,
            targetX: 0,
            underlying: underlying
        )
    }

    private func productEquation(underlying: Equation, reaction: BalancedReactionEquations) -> Equation {
        ScaledEquation(
            targetY: 1,
            targetX: reaction.convergenceTime,
            underlying: underlying
        )
    }

}

struct ReverseGridMolecules {

    let forwardGrid: ForwardGridMolecules
    let forwardReaction: BalancedReactionEquations

    func aGrid(reaction: BalancedReactionEquations) -> FractionedCoordinates {
        FractionedCoordinates(
            coordinates: finalAGrid(reaction: reaction),
            fractionToDraw: reactantFractionToDraw(
                underlying: reaction.reactantA,
                forwardUnderlying: forwardReaction.reactantA,
                gridCount: finalAGrid(reaction: reaction).count
            )
        )
    }

    func bGrid(reaction: BalancedReactionEquations) -> FractionedCoordinates {
        FractionedCoordinates(
            coordinates: finalBGrid(reaction: reaction),
            fractionToDraw: reactantFractionToDraw(
                underlying: reaction.reactantB,
                forwardUnderlying: forwardReaction.reactantB,
                gridCount: finalBGrid(reaction: reaction).count
            )
        )
    }

    func cGrid(reaction: BalancedReactionEquations) -> FractionedCoordinates {
        FractionedCoordinates(
            coordinates: underlyingCGrid,
            fractionToDraw: productFractionToDraw(
                underlying: reaction.productC,
                tAddProduct: AqueousReactionSettings.timeToAddProduct
            )
        )
    }

    func dGrid(reaction: BalancedReactionEquations) -> FractionedCoordinates {
        FractionedCoordinates(
            coordinates: underlyingDGrid,
            fractionToDraw: productFractionToDraw(
                underlying: reaction.productD,
                tAddProduct: AqueousReactionSettings.timeToAddProduct
            )
        )
    }


    init(forwardGrid: ForwardGridMolecules, forwardReaction: BalancedReactionEquations) {
        self.forwardGrid = forwardGrid
        self.forwardReaction = forwardReaction

        let initA = Self.initReactantGrid(
            forwardGrid: forwardGrid.aGrid(reaction: forwardReaction),
            convergenceTime: forwardReaction.convergenceTime
        )
        let initB = Self.initReactantGrid(
            forwardGrid: forwardGrid.bGrid(reaction: forwardReaction),
            convergenceTime: forwardReaction.convergenceTime
        )

        let shuffledCoords = EquilibriumGridSettings.grid.shuffled()
        self.shuffledAvailableReactantCoords = shuffledCoords.filter { coord in
            !initA.contains(coord) && !initB.contains(coord)
        }
        self.initialAGrid = initA
        self.initialBGrid = initB
        self.underlyingCGrid = forwardGrid.cGrid(reaction: forwardReaction).coordinates
        self.underlyingDGrid = forwardGrid.dGrid(reaction: forwardReaction).coordinates
    }

    private let shuffledAvailableReactantCoords: [GridCoordinate]
    private var initialAGrid: [GridCoordinate]
    private var initialBGrid: [GridCoordinate]
    private var underlyingCGrid: [GridCoordinate]
    private var underlyingDGrid: [GridCoordinate]

    mutating func setConcentration(of product: AqueousMoleculeProduct, concentration: CGFloat) {
        let newMolecules = GridMoleculesUtil.settingGridMoleculesConcentration(
            molecules: product == .C ? underlyingCGrid : underlyingDGrid,
            concentration: concentration,
            avoiding: product == .C ? underlyingDGrid : underlyingCGrid
        )
        if product == .C {
            underlyingCGrid = newMolecules
        } else {
            underlyingDGrid = newMolecules
        }
    }

    private func finalAGrid(reaction: BalancedReactionEquations) -> [GridCoordinate] {
        initialAGrid + extraACoords(reaction: reaction)
    }

    private func finalBGrid(reaction: BalancedReactionEquations) -> [GridCoordinate] {
        initialBGrid + extraBCoords(reaction: reaction)
    }

    private func extraACoords(reaction: BalancedReactionEquations) -> [GridCoordinate] {
        let extra = reactantExtraCount(
            underlying: reaction.reactantA,
            convergenceTime: reaction.convergenceTime,
            gridCount: initialAGrid.count
        )
        return Array(shuffledAvailableReactantCoords.prefix(extra))
    }

    private func extraBCoords(reaction: BalancedReactionEquations) -> [GridCoordinate] {
        let extra = reactantExtraCount(
            underlying: reaction.reactantB,
            convergenceTime: reaction.convergenceTime,
            gridCount: initialBGrid.count
        )
        let aCount = extraACoords(reaction: reaction).count
        let coords = shuffledAvailableReactantCoords.dropFirst(aCount).prefix(extra)
        return Array(coords)
    }

    private func reactantExtraCount(underlying: Equation, convergenceTime: CGFloat, gridCount: Int) -> Int {
        let finalConcentration = underlying.getY(at: convergenceTime)
        let finalNum = GridMoleculesUtil.equilibriumGridCount(for: finalConcentration)
        return finalNum - gridCount
    }

    private func aFractionToDraw(underlying: Equation, reaction: BalancedReactionEquations) -> Equation {
        let startConcentration = forwardReaction.reactantA.getY(at: forwardReaction.convergenceTime)
        let startNum = GridMoleculesUtil.equilibriumGridCount(for: startConcentration)
        let startFraction = CGFloat(startNum) / CGFloat(finalAGrid(reaction: reaction).count)
        return ScaledEquation(
            targetY: startFraction,
            targetX: AqueousReactionSettings.timeToAddProduct,
            underlying: underlying
        )
    }

    private func reactantFractionToDraw(
        underlying: Equation,
        forwardUnderlying: Equation,
        gridCount: Int
    ) -> Equation {
        let startConcentration = forwardUnderlying.getY(at: forwardReaction.convergenceTime)
        let startNum = GridMoleculesUtil.equilibriumGridCount(for: startConcentration)
        let startFraction = CGFloat(startNum) / CGFloat(gridCount)
        return ScaledEquation(
            targetY: startFraction,
            targetX: AqueousReactionSettings.timeToAddProduct,
            underlying: underlying
        )
    }

    private static func initReactantGrid(
        forwardGrid: FractionedCoordinates,
        convergenceTime: CGFloat
    ) -> [GridCoordinate] {
        let initFraction = forwardGrid.fractionToDraw.getY(at: convergenceTime)
        let initCount = (initFraction * CGFloat(forwardGrid.coordinates.count)).roundedInt()
        return Array(forwardGrid.coordinates.prefix(initCount))
    }

    private func productFractionToDraw(underlying: Equation, tAddProduct: CGFloat) -> Equation {
        ScaledEquation(
            targetY: 1,
            targetX: tAddProduct,
            underlying: underlying
        )
    }

}
