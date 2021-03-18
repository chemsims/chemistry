//
// Reactions App
//

import ReactionsCore
import CoreGraphics

let maxC: CGFloat = 0.3

class ReactionComponentsWrapper {

    let cols: Int
    var rows: Int {
        didSet {
            setComponents()
        }
    }
    var coefficients: BalancedReactionCoefficients {
        didSet {
            setComponents()
        }
    }
    var equilibriumConstant: CGFloat {
        didSet {
            setComponents()
        }
    }

    let startTime: CGFloat
    let equilibriumTime: CGFloat
    let previous: ReactionComponentsWrapper?

    private(set) var molecules: MoleculeValue<[GridCoordinate]>

    init(
        coefficients: BalancedReactionCoefficients,
        equilibriumConstant: CGFloat,
        cols: Int,
        rows: Int,
        maxRows: Int,
        startTime: CGFloat,
        equilibriumTime: CGFloat
    ) {
        self.cols = cols
        self.rows = rows
        self.coefficients = coefficients
        self.equilibriumConstant = equilibriumConstant
        self.startTime = startTime
        self.equilibriumTime = equilibriumTime
        self.previous = nil
        self.molecules = MoleculeValue(builder: { _ in [] })
        self.components = ReactionComponents(
            initialBeakerMolecules: MoleculeValue(builder: { _ in [] }),
            coefficients: coefficients,
            equilibriumConstant: equilibriumConstant,
            shuffledCoords: GridCoordinate.grid(cols: cols, rows: maxRows).shuffled(),
            gridSize: cols * rows,
            startTime: startTime,
            equilibriumTime: equilibriumTime,
            previousEquation: nil
        )
    }

    init(
        previous: ReactionComponentsWrapper,
        startTime: CGFloat,
        equilibriumTime: CGFloat
    ) {
        self.cols = previous.cols
        self.rows = previous.rows
        self.coefficients = previous.coefficients
        self.equilibriumConstant = previous.equilibriumConstant
        self.startTime = startTime
        self.equilibriumTime = equilibriumTime
        self.previous = previous
        let filteredMolecules = Self.consolidate(
            molecules: previous.components.beakerMolecules,
            at: previous.components.equation.equilibriumTime
        )
        self.molecules = filteredMolecules
        self.components = ReactionComponents(
            initialBeakerMolecules: filteredMolecules,
            coefficients: previous.coefficients,
            equilibriumConstant: previous.equilibriumConstant,
            shuffledCoords: previous.components.shuffledCoords,
            gridSize: previous.gridSize,
            startTime: startTime,
            equilibriumTime: equilibriumTime,
            previousEquation: previous.components.equation
        )
    }

    func increment(molecule: AqueousMolecule, count: Int) {
        let current = molecules.value(for: molecule)
        let avoid = molecules.all.flatten
        let maxAdd = maximumToAdd(to: current, maxConcentration: maxC)
        let toAdd = min(maxAdd, count)
        guard toAdd > 0 else { return }
        let newCoords = GridCoordinateList.addingRandomElementsTo(
            grid: current,
            count: toAdd,
            cols: cols,
            rows: rows,
            avoiding: avoid
        )
        molecules = molecules.updating(with: newCoords, for: molecule)
        setComponents()
    }

    private(set) var components: ReactionComponents

    private func setComponents() {
        components = ReactionComponents(
            initialBeakerMolecules: molecules,
            coefficients: coefficients,
            equilibriumConstant: equilibriumConstant,
            shuffledCoords: components.shuffledCoords,
            gridSize: gridSize,
            startTime: startTime,
            equilibriumTime: equilibriumTime,
            previousEquation: components.previousEquation
        )
    }

    var gridSize: Int {
        cols * rows
    }

    func concentrationIncremented(of molecule: AqueousMolecule) -> CGFloat {
        func getConcentration(from components: ReactionComponents, at time: CGFloat) -> CGFloat {
            let molecules = components.beakerMolecules.first { $0.molecule == molecule }?.animatingMolecules
            let fraction = molecules.map {
                FractionedCoordinates(
                    coordinates: $0.molecules.coords,
                    fractionToDraw: $0.fractionToDraw
                )
            }
            let count = fraction?.coords(at: time).count ?? 0
            return CGFloat(count) / CGFloat(gridSize)
        }

        let currentC = getConcentration(from: components, at: startTime)
        let previousC = previous.map { getConcentration(from: $0.components, at: $0.equilibriumTime) }

        return currentC - (previousC ?? 0)
    }

}

extension ReactionComponentsWrapper {
    func canIncrement(molecule: AqueousMolecule) -> Bool {
        maximumToAdd(
            to: molecules.value(for: molecule),
            maxConcentration: maxC
        ) > 0
    }

    fileprivate func maximumToAdd(
        to existing: [GridCoordinate],
        maxConcentration: CGFloat
    ) -> Int {
        let available = CGFloat(gridSize)
        let maxCount = (maxConcentration * available).roundedInt()
        return maxCount - existing.count
    }
}

extension ReactionComponentsWrapper {
    static func consolidate(
        molecules: [LabelledAnimatingBeakerMolecules],
        at time: CGFloat
    ) -> MoleculeValue<[GridCoordinate]> {
        let fractionedCoords = molecules.map {
            FractionedCoordinates(
                coordinates: $0.animatingMolecules.molecules.coords,
                fractionToDraw: $0.animatingMolecules.fractionToDraw
            )
        }
        let visibleMolecules = fractionedCoords.map {
            $0.coords(at: time)
        }

        var builder = [AqueousMolecule:[GridCoordinate]]()

        for i in 0..<visibleMolecules.count {
            let element = molecules[i].molecule
            let others = Array(visibleMolecules[i+1..<visibleMolecules.count]).flatten
            let current = visibleMolecules[i]
            let filtered = current.filter {
                !others.contains($0)
            }
            builder[element] = filtered
        }
        return MoleculeValue(builder: { builder[$0] ?? [] })
    }
}

class ReactionComponents {

    let initialBeakerMolecules: MoleculeValue<[GridCoordinate]>
    let coefficients: BalancedReactionCoefficients
    let equilibriumConstant: CGFloat
    let shuffledCoords: [GridCoordinate]
    let gridSize: Int
    let startTime: CGFloat
    let equilibriumTime: CGFloat
    let previousEquation: NewBalancedReactionEquation?

    init(
        initialBeakerMolecules: MoleculeValue<[GridCoordinate]>,
        coefficients: BalancedReactionCoefficients,
        equilibriumConstant: CGFloat,
        shuffledCoords: [GridCoordinate],
        gridSize: Int,
        startTime: CGFloat,
        equilibriumTime: CGFloat,
        previousEquation: NewBalancedReactionEquation?
    ) {
        self.initialBeakerMolecules = initialBeakerMolecules
        self.coefficients = coefficients
        self.equilibriumConstant = equilibriumConstant
        self.shuffledCoords = shuffledCoords
        self.gridSize = gridSize
        self.startTime = startTime
        self.equilibriumTime = equilibriumTime
        self.previousEquation = previousEquation
    }

    lazy var equation = NewBalancedReactionEquation(
        coefficients: coefficients,
        equilibriumConstant: equilibriumConstant,
        initialConcentrations: initialBeakerMolecules.map(getConcentration),
        startTime: startTime,
        equilibriumTime: equilibriumTime,
        previous: previousEquation
    )

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

    private(set) lazy var quotientEquation: Equation = ReactionQuotientEquation(equations: equation)

    private(set) lazy var quotientChartDiscontinuity: CGPoint? = {
        guard startTime > 0 else {
            return nil
        }
        return CGPoint(
            x: AqueousReactionSettings.timeToAddProduct,
            y: quotientEquation.getY(at: startTime)
        )
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
        grid: shuffledCoords
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
            fractionToDraw: beakerFractionToDraw(for: balancedElement)
        )
        return LabelledAnimatingBeakerMolecules(
            molecule: element,
            animatingMolecules: model
        )
    }

    private func beakerFractionToDraw(for element: BalancedGridElement?) -> Equation {
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

    private func getConcentration(of coordinates: [GridCoordinate]) -> CGFloat {
        CGFloat(coordinates.count) / CGFloat(gridSize)
    }

    private func getCount(for concentration: CGFloat) -> Int {
        (CGFloat(gridSize) * concentration).roundedInt()
    }

    private(set) lazy var tForMaxQuotient: CGFloat =
        equation.isForward ? equilibriumTime : startTime

}

struct LabelledAnimatingBeakerMolecules {
    let molecule: AqueousMolecule
    let animatingMolecules: AnimatingBeakerMolecules
}

struct NewBalancedReactionEquation {

    let startTime: CGFloat
    let equilibriumTime: CGFloat
    let concentration: MoleculeValue<Equation>
    let direction: ReactionDirection
    let coefficients: MoleculeValue<Int>

    let initialConcentrations: MoleculeValue<CGFloat>

    var isForward: Bool {
        direction == .forward
    }

    init(
        coefficients: BalancedReactionCoefficients,
        equilibriumConstant: CGFloat,
        initialConcentrations: MoleculeValue<CGFloat>,
        startTime: CGFloat,
        equilibriumTime: CGFloat,
        previous: NewBalancedReactionEquation?
    ) {
        self.startTime = startTime
        self.equilibriumTime = equilibriumTime
        self.initialConcentrations = initialConcentrations
        self.coefficients = coefficients

        let direction = Self.getDirection(
            coefficients: coefficients,
            equilibriumConstant: equilibriumConstant,
            initialConcentrations: initialConcentrations
        )
        self.direction = direction
        let isForward = direction == .forward

        let unitChange = ReactionConvergenceSolver.findUnitChangeFor(
            equilibriumConstant: equilibriumConstant,
            coeffs: coefficients,
            initialConcentrations: initialConcentrations,
            isForward: direction == .forward
        )

        func getTerm(_ molecule: AqueousMolecule) -> MoleculeTerms {
            MoleculeTerms(
                initC: initialConcentrations.value(for: molecule),
                coeff: coefficients.value(for: molecule),
                increases: molecule.isReactant ? !isForward : isForward
            )
        }

        let equations = BalancedEquationBuilder.getEquations(
            terms: MoleculeValue(builder: getTerm),
            startTime: startTime,
            convergenceTime: equilibriumTime,
            unitChange: unitChange ?? 0
        )

        let combinedWithPrevious: MoleculeValue<Equation>? = previous.map { previous in
            previous.concentration.combine(
                with: equations,
                using: {
                    SwitchingEquation(
                        thresholdX: startTime,
                        underlyingLeft: $0,
                        underlyingRight: $1
                    )
                }
            )
        }

        self.concentration = combinedWithPrevious ?? equations
    }

    lazy var equilibriumConcentrations: MoleculeValue<CGFloat> = concentration.map {
        $0.getY(at: equilibriumTime)
    }

    private static func getDirection(
        coefficients: MoleculeValue<Int>,
        equilibriumConstant: CGFloat,
        initialConcentrations: MoleculeValue<CGFloat>
    ) -> ReactionDirection {
        let initialQuotient = ReactionQuotientEquation(
            coefficients: coefficients,
            equations: initialConcentrations.map {
                ConstantEquation(value: $0)
            }
        ).getY(at: 0)
        return initialQuotient < equilibriumConstant ? .forward : .reverse
    }
}
