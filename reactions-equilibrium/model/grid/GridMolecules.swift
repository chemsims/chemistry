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
        gridCount(for: concentration, gridSize: EquilibriumGridSettings.grid.count)
    }

    static func gridCount(for concentration: CGFloat, gridSize: Int) -> Int {
        (concentration * CGFloat(gridSize)).roundedInt()
    }
}

struct ForwardGridMolecules {

    private let shuffledEquilibriumGrid = EquilibriumGridSettings.grid.shuffled()

    func aGrid(reaction: BalancedReactionEquations) -> FractionedCoordinates {
        FractionedCoordinates(
            coordinates: underlyingAGrid,
            fractionToDraw: MoleculeGridFractionToDraw(
                underlyingConcentration: reaction.reactantA,
                initialConcentration: reaction.initialConcentrations.reactantA,
                finalConcentration: reaction.reactantA.getY(at: reaction.convergenceTime),
                gridCount: underlyingAGrid.count,
                totalGridCount: EquilibriumGridSettings.grid.count
            )
        )
    }

    func bGrid(reaction: BalancedReactionEquations) -> FractionedCoordinates {
        FractionedCoordinates(
            coordinates: underlyingBGrid,
            fractionToDraw: MoleculeGridFractionToDraw(
                underlyingConcentration: reaction.reactantB,
                initialConcentration: reaction.initialConcentrations.reactantA,
                finalConcentration: reaction.reactantB.getY(at: reaction.convergenceTime),
                gridCount: underlyingBGrid.count,
                totalGridCount: EquilibriumGridSettings.grid.count
            )
        )
    }

    func cGrid(reaction: BalancedReactionEquations) -> FractionedCoordinates {
        FractionedCoordinates(
            coordinates: underlyingCGrid(reaction: reaction),
            fractionToDraw: MoleculeGridFractionToDraw(
                underlyingConcentration: reaction.productC,
                initialConcentration: 0,
                finalConcentration: reaction.productC.getY(at: reaction.convergenceTime),
                gridCount: underlyingCGrid(reaction: reaction).count,
                totalGridCount: EquilibriumGridSettings.grid.count
            )
        )
    }

    func dGrid(reaction: BalancedReactionEquations) -> FractionedCoordinates {
        FractionedCoordinates(
            coordinates: underlyingDGrid(reaction: reaction),
            fractionToDraw: MoleculeGridFractionToDraw(
                underlyingConcentration: reaction.productD,
                initialConcentration: 0,
                finalConcentration: reaction.productD.getY(at: reaction.convergenceTime),
                gridCount: underlyingDGrid(reaction: reaction).count,
                totalGridCount: EquilibriumGridSettings.grid.count
            )
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
}

struct ReverseGridMolecules {

    let forwardGrid: ForwardGridMolecules
    let forwardReaction: BalancedReactionEquations

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

    func aGrid(reaction: BalancedReactionEquations) -> FractionedCoordinates {
        FractionedCoordinates(
            coordinates: finalAGrid(reaction: reaction),
            fractionToDraw: MoleculeGridFractionToDraw(
                underlyingConcentration: reaction.reactantA,
                initialConcentration: reaction.reactantA.getY(at: AqueousReactionSettings.timeToAddProduct),
                finalConcentration: reaction.reactantA.getY(at: reaction.convergenceTime),
                gridCount: finalAGrid(reaction: reaction).count,
                totalGridCount: EquilibriumGridSettings.grid.count
            )
        )
    }

    func bGrid(reaction: BalancedReactionEquations) -> FractionedCoordinates {
        FractionedCoordinates(
            coordinates: finalBGrid(reaction: reaction),
            fractionToDraw: MoleculeGridFractionToDraw(
                underlyingConcentration: reaction.reactantB,
                initialConcentration: reaction.reactantB.getY(at: AqueousReactionSettings.timeToAddProduct),
                finalConcentration: reaction.reactantB.getY(at: reaction.convergenceTime),
                gridCount: finalBGrid(reaction: reaction).count,
                totalGridCount: EquilibriumGridSettings.grid.count
            )
        )
    }

    func cGrid(reaction: BalancedReactionEquations) -> FractionedCoordinates {
        FractionedCoordinates(
            coordinates: underlyingCGrid,
            fractionToDraw: MoleculeGridFractionToDraw(
                underlyingConcentration: reaction.productC,
                initialConcentration: reaction.productC.getY(at: AqueousReactionSettings.timeToAddProduct),
                finalConcentration: reaction.productC.getY(at: reaction.convergenceTime),
                gridCount: underlyingCGrid.count,
                totalGridCount: EquilibriumGridSettings.grid.count
            )
        )
    }

    func dGrid(reaction: BalancedReactionEquations) -> FractionedCoordinates {
        FractionedCoordinates(
            coordinates: underlyingDGrid,
            fractionToDraw: MoleculeGridFractionToDraw(
                underlyingConcentration: reaction.productD,
                initialConcentration: reaction.productD.getY(at: AqueousReactionSettings.timeToAddProduct),
                finalConcentration: reaction.productD.getY(at: reaction.convergenceTime),
                gridCount: underlyingDGrid.count,
                totalGridCount: EquilibriumGridSettings.grid.count
            )
        )
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


    private static func initReactantGrid(
        forwardGrid: FractionedCoordinates,
        convergenceTime: CGFloat
    ) -> [GridCoordinate] {
        let initFraction = forwardGrid.fractionToDraw.getY(at: convergenceTime)
        let initCount = (initFraction * CGFloat(forwardGrid.coordinates.count)).roundedInt()
        return Array(forwardGrid.coordinates.prefix(initCount))
    }
}

struct MoleculeGridFractionToDraw: Equation {

    let underlyingConcentration: Equation
    let initialNumToDraw: Int
    let initialFraction: CGFloat
    let finalNumToDraw: Int
    let finalFraction: CGFloat
    let totalGridCount: Int

    init(
        underlyingConcentration: Equation,
        initialConcentration: CGFloat,
        finalConcentration: CGFloat,
        gridCount: Int,
        totalGridCount: Int
    ) {
        self.underlyingConcentration = underlyingConcentration
        self.totalGridCount = totalGridCount

        let initialNumToDraw = GridMoleculesUtil.gridCount(for: initialConcentration.rounded(decimals: 4), gridSize: totalGridCount)
        self.initialNumToDraw = initialNumToDraw
        self.initialFraction = gridCount == 0 ? 0 : CGFloat(initialNumToDraw) / CGFloat(gridCount)

        let finalNumToDraw = GridMoleculesUtil.gridCount(for: finalConcentration.rounded(decimals: 4), gridSize: totalGridCount)
        self.finalNumToDraw = finalNumToDraw
        self.finalFraction = gridCount == 0 ? 0 : CGFloat(finalNumToDraw) / CGFloat(gridCount)
    }

    func getY(at x: CGFloat) -> CGFloat {
        let concentration = underlyingConcentration.getY(at: x)
        let numToDraw = GridMoleculesUtil.gridCount(for: concentration, gridSize: totalGridCount)
        let numer = (finalFraction - initialFraction) * CGFloat(numToDraw - initialNumToDraw)
        let denom = CGFloat(finalNumToDraw - initialNumToDraw)

        let addTerm = denom == 0 ? 0 : numer / denom
        return (initialFraction + addTerm)
    }
}
