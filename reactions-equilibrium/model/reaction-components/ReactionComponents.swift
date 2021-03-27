//
// Reactions App
//

import ReactionsCore
import CoreGraphics

class ReactionComponents {

    let initialBeakerMolecules: MoleculeValue<[GridCoordinate]>
    let coefficients: BalancedReactionCoefficients
    let equilibriumConstant: CGFloat
    let shuffledBeakerCoords: [GridCoordinate]
    let beakerGridSize: Int
    let initialGridMolecules: MoleculeValue<[GridCoordinate]>
    let shuffledEquilibriumGrid: [GridCoordinate]
    let startTime: CGFloat
    let equilibriumTime: CGFloat
    let previousEquation: BalancedReactionEquation?
    let previousMolecules: MoleculeValue<[GridCoordinate]>?
    let rowsHaveChangeFromPrevious: Bool?
    let usePressureValues: Bool

    init(
        initialBeakerMolecules: MoleculeValue<[GridCoordinate]>,
        coefficients: BalancedReactionCoefficients,
        equilibriumConstant: CGFloat,
        shuffledBeakerCoords: [GridCoordinate],
        beakerGridSize: Int,
        initialGridMolecules: MoleculeValue<[GridCoordinate]>,
        shuffledEquilibriumGrid: [GridCoordinate],
        startTime: CGFloat,
        equilibriumTime: CGFloat,
        previousEquation: BalancedReactionEquation?,
        previousMolecules: MoleculeValue<[GridCoordinate]>?,
        rowsHaveChangeFromPrevious: Bool?,
        usePressureValues: Bool = false
    ) {
        self.initialBeakerMolecules = initialBeakerMolecules
        self.coefficients = coefficients
        self.equilibriumConstant = equilibriumConstant
        self.shuffledBeakerCoords = shuffledBeakerCoords
        self.beakerGridSize = beakerGridSize
        self.initialGridMolecules = initialGridMolecules
        self.shuffledEquilibriumGrid = shuffledEquilibriumGrid
        self.startTime = startTime
        self.equilibriumTime = equilibriumTime
        self.previousEquation = previousEquation
        self.previousMolecules = previousMolecules
        self.rowsHaveChangeFromPrevious = rowsHaveChangeFromPrevious
        self.usePressureValues = usePressureValues
    }

    lazy var equation = BalancedReactionEquation(
        coefficients: coefficients,
        equilibriumConstant: equilibriumConstant,
        initialConcentrations: MoleculeValue(builder: getConcentration),
        startTime: startTime,
        equilibriumTime: equilibriumTime,
        previous: previousEquation,
        usePressureValues: usePressureValues
    )

    private(set) lazy var equilibriumGrid = MoleculeValue(
        reactantA: getFractionedCoords(for: reactantGridSetter.balancedElements[0]),
        reactantB: getFractionedCoords(for: reactantGridSetter.balancedElements[1]),
        productC: getFractionedCoords(for: productGridSetter.balancedElements[0]),
        productD: getFractionedCoords(for: productGridSetter.balancedElements[1])
    )

    private lazy var reactantGridSetter = getGridSetter(molecules: [.A, .B])
    private lazy var productGridSetter = getGridSetter(molecules: [.C, .D])

    private func getFractionedCoords(for element: BalancedGridElement) -> FractionedCoordinates {
        FractionedCoordinates(coordinates: element.coords, fractionToDraw: balancedFractionToDraw(for: element))
    }

    private func getGridSetter(molecules: [AqueousMolecule]) -> GridElementSetter {
        GridElementSetter(
            elements: molecules.map(getEquilibriumElementToBalance),
            shuffledCoords: shuffledEquilibriumGrid
        )
    }

    private func getEquilibriumElementToBalance(molecule: AqueousMolecule) -> GridElementToBalance {
        let finalConcentration = equation.equilibriumConcentrations.value(for: molecule)
        let finalCount = (finalConcentration * CGFloat(shuffledEquilibriumGrid.count)).roundedInt()
        return GridElementToBalance(
            initialCoords: initialGridMolecules.value(for: molecule),
            finalCount: finalCount
        )
    }

    private(set) lazy var beakerMolecules: [LabelledAnimatingBeakerMolecules] = {
        var builder = [LabelledAnimatingBeakerMolecules]()
        func add(_ molecule: AqueousMolecule) {
            builder.append(getBeakerMolecules(for: molecule))
        }
        func addReactants() {
            add(.A)
            add(.B)
        }

        func addProducts() {
            add(.C)
            add(.D)
        }


        if equation.isForward {
            addReactants()
            addProducts()
        } else {
            addProducts()
            addReactants()
        }
        return builder
    }()

    private(set) lazy var moleculeChartDiscontinuities: MoleculeValue<CGPoint>? = {
        guard startTime > 0 else {
            return nil
        }
        return equation.concentration.map {
            CGPoint(x: startTime, y: $0.getY(at: startTime))
        }
    }()

    private(set) lazy var quotientEquation: Equation = ReactionQuotientEquation(
        equations: equation
    )

    private(set) lazy var pressureQuotientEquation: Equation = ReactionQuotientEquation(
        coefficients: equation.coefficients,
        equations: equation.pressure
    )

    private(set) lazy var quotientChartDiscontinuity: CGPoint? = {
        guard startTime > 0 else {
            return nil
        }
        return CGPoint(
            x: startTime,
            y: quotientEquation.getY(at: startTime)
        )
    }()

    private(set) lazy var maxQuotient: CGFloat = {
        let currentMax = max(
            quotientEquation.getY(at: startTime),
            quotientEquation.getY(at: equilibriumTime)
        )
        if let previous = previousEquation {
            let prevQ = ReactionQuotientEquation(equations: previous)
            let prevMax = max(prevQ.getY(at: previous.startTime), prevQ.getY(at: previous.equilibriumTime))
            return max(prevMax, currentMax)
        }
        return currentMax
    }()

    private lazy var balancedMoleculeValues: MoleculeValue<BalancedGridElement?> = {
        let reactants = equation.isForward ? gridBalancer?.decreasingBalanced : gridBalancer?.increasingBalanced
        let products = equation.isForward ? gridBalancer?.increasingBalanced : gridBalancer?.decreasingBalanced
        return MoleculeValue(
            reactantA: reactants?.first,
            reactantB: reactants?.second,
            productC: products?.first,
            productD: products?.second
        )
    }()

    private lazy var gridBalancer = GridElementBalancer(
        increasingElements: equation.isForward ? productPair : reactantPair,
        decreasingElements: equation.isForward ? reactantPair : productPair,
        grid: shuffledBeakerCoords
    )

    private var reactantPair: GridElementPair<GridElementToBalance> {
        GridElementPair(
            first: GridElementToBalance(
                initialCoords: initialBeakerMolecules.reactantA,
                finalCount: getCount(
                    for: equation.equilibriumConcentrations.reactantA
                )
            ),
            second: GridElementToBalance(
                initialCoords: initialBeakerMolecules.reactantB,
                finalCount: getCount(
                    for: equation.equilibriumConcentrations.reactantB
                )
            )
        )
    }

    private var productPair: GridElementPair<GridElementToBalance> {
        GridElementPair(
            first: GridElementToBalance(
                initialCoords: initialBeakerMolecules.productC,
                finalCount: getCount(
                    for: equation.equilibriumConcentrations.productC
                )
            ),
            second: GridElementToBalance(
                initialCoords: initialBeakerMolecules.productD,
                finalCount: getCount(
                    for: equation.equilibriumConcentrations.productD
                )
            )
        )
    }

    private func getBeakerMolecules(for element: AqueousMolecule) -> LabelledAnimatingBeakerMolecules {
        let balancedElement = balancedMoleculeValues.value(for: element)
        let model = AnimatingBeakerMolecules(
            molecules: BeakerMolecules(
                coords: balancedElement?.coords ?? initialBeakerMolecules.value(for: element),
                color: element.color
            ),
            fractionToDraw: balancedFractionToDraw(for: balancedElement)
        )
        return LabelledAnimatingBeakerMolecules(
            molecule: element,
            animatingMolecules: model
        )
    }

    private func balancedFractionToDraw(for element: BalancedGridElement?) -> Equation {
        if let element = element {
            return EquilibriumReactionEquation(
                t1: equation.startTime,
                c1: CGFloat(element.initialFraction),
                t2: equation.equilibriumTime,
                c2: CGFloat(element.finalFraction)
            )
        }
        return ConstantEquation(value: 1)
    }

    /// Finding concentration using the molecule count may differ from the previously converged value
    /// So, if molecules unchanged, use the previous equilibrium value
    private func getConcentration(of molecule: AqueousMolecule) -> CGFloat {
        GridUtil.initialConcentration(
            of: molecule,
            coords: initialBeakerMolecules.value(for: molecule),
            gridSize: beakerGridSize,
            previousCoords: previousMolecules?.value(for: molecule),
            previousEquation: previousEquation,
            at: startTime,
            rowsHaveChangeFromPrevious: rowsHaveChangeFromPrevious
        )
    }

    private func getCount(for concentration: CGFloat) -> Int {
        (CGFloat(beakerGridSize) * concentration).roundedInt()
    }

    private(set) lazy var tForMaxQuotient: CGFloat =
        equation.isForward ? equilibriumTime : startTime

}
