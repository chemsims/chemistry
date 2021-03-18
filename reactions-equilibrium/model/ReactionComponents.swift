//
// Reactions App
//

import ReactionsCore
import CoreGraphics

struct ReactionComponentsWrapper {

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

    private(set) var molecules: MoleculeValue<[GridCoordinate]>

    init(
        coefficients: BalancedReactionCoefficients,
        equilibriumConstant: CGFloat,
        cols: Int,
        rows: Int,
        maxRows: Int
    ) {
        self.cols = cols
        self.rows = rows
        self.coefficients = coefficients
        self.equilibriumConstant = equilibriumConstant
        self.molecules = MoleculeValue(builder: { _ in [] })
        self.components = ReactionComponents(
            initialBeakerMolecules: MoleculeValue(builder: { _ in [] }),
            coefficients: coefficients,
            equilibriumConstant: equilibriumConstant,
            shuffledCoords: GridCoordinate.grid(cols: cols, rows: maxRows).shuffled(),
            gridSize: cols * rows
        )
    }

    mutating func increment(molecule: AqueousMolecule, count: Int) {
        let current = molecules.value(for: molecule)
        let avoid = molecules.all.flatten
        let newCoords = GridCoordinateList.addingRandomElementsTo(
            grid: current,
            count: count,
            cols: cols,
            rows: rows,
            avoiding: avoid
        )
        molecules = molecules.updating(with: newCoords, for: molecule)
        setComponents()
    }

    private(set) var components: ReactionComponents

    private mutating func setComponents() {
        components = ReactionComponents(
            initialBeakerMolecules: molecules,
            coefficients: coefficients,
            equilibriumConstant: equilibriumConstant,
            shuffledCoords: components.shuffledCoords,
            gridSize: cols * rows
        )
    }
}

class ReactionComponents {

    let initialBeakerMolecules: MoleculeValue<[GridCoordinate]>
    let coefficients: BalancedReactionCoefficients
    let equilibriumConstant: CGFloat
    let shuffledCoords: [GridCoordinate]
    let gridSize: Int

    init(
        initialBeakerMolecules: MoleculeValue<[GridCoordinate]>,
        coefficients: BalancedReactionCoefficients,
        equilibriumConstant: CGFloat,
        shuffledCoords: [GridCoordinate],
        gridSize: Int
    ) {
        self.initialBeakerMolecules = initialBeakerMolecules
        self.coefficients = coefficients
        self.equilibriumConstant = equilibriumConstant
        self.shuffledCoords = shuffledCoords
        self.gridSize = gridSize
    }

    lazy var equation = NewBalancedReactionEquation(
        coefficients: coefficients,
        equilibriumConstant: equilibriumConstant,
        initialConcentrations: initialBeakerMolecules.map(getConcentration),
        startTime: 1,
        equilibriumTime: 10,
        previous: nil
    )

    private(set) lazy var beakerMolecules: [AnimatingBeakerMolecules] = {
        var builder = [AnimatingBeakerMolecules]()
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
                finalCount: 1
            ),
            second: GridElementToBalance(
                initialCoords: initialBeakerMolecules.reactantB,
                finalCount: 1
            )
        )
    }

    private var productPair: GridElementPair<GridElementToBalance> {
        GridElementPair(
            first: GridElementToBalance(
                initialCoords: initialBeakerMolecules.productC,
                finalCount: 1
            ),
            second: GridElementToBalance(
                initialCoords: initialBeakerMolecules.productD,
                finalCount: 1
            )
        )
    }

    private func getBeakerMolecules(for element: AqueousMolecule) -> AnimatingBeakerMolecules {
        let balancedElement = balancedMoleculeValues.value(for: element)
        return AnimatingBeakerMolecules(
            molecules: BeakerMolecules(
                coords: balancedElement?.coords ?? initialBeakerMolecules.value(for: element),
                color: element.color
            ),
            fractionToDraw: beakerFractionToDraw(for: balancedElement)
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
