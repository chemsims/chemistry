//
// Reactions App
//

import XCTest
@testable import reactions_equilibrium
@testable import ReactionsCore

class ReactionComponentTests: XCTestCase {

    func testIncrementingAMolecules() {
        var model = newModel()

        model.beakerCoords.forEach {
            XCTAssert($0.isEmpty)
        }

        model.increment(molecule: .A, count: 1)
        XCTAssertEqual(model.beakerCoords[0].count, 1)

        model.increment(molecule: .A, count: 1)
        XCTAssertEqual(model.beakerCoords[0].count, 2)
    }

    func testIncrementingAMoleculesToMaxCount() {
        var model = newModel()
        XCTAssert(model.canIncrement(molecule: .A))

        model.increment(molecule: .A, count: maxIncrementCount)

        XCTAssertEqual(model.beakerCoords[0].count, maxMolecules)
        XCTAssertFalse(model.canIncrement(molecule: .A))

        model.increment(molecule: .A, count: 1)
        XCTAssertEqual(model.beakerCoords[0].count, maxMolecules)
    }

    func testIncrementingBMolecules() {
        var model = newModel()
        model.increment(molecule: .A, count: maxIncrementCount)
        model.increment(molecule: .B, count: maxIncrementCount)

        let aCoords = model.beakerCoords[0]
        let bCoords = model.beakerCoords[1]

        XCTAssertEqual(aCoords.count, maxMolecules)
        XCTAssertEqual(bCoords.count, maxMolecules)

        bCoords.forEach { molecule in
            XCTAssertFalse(aCoords.contains(molecule))
        }
    }

    func testA0AndB0AreCorrect() {
        var model = newModel()
        model.increment(molecule: .A, count: maxIncrementCount)
        model.increment(molecule: .B, count: maxIncrementCount)

        let concentration = model.components.equation.concentration
        XCTAssertEqual(
            concentration.reactantA.getY(at: 0),
            maxConcentration, accuracy: 0.0001
        )
        XCTAssertEqual(
            concentration.reactantB.getY(at: 0),
            maxConcentration, accuracy: 0.0001
        )
    }

    func testEquationConverges() {
        var model = newModel()
        model.increment(molecule: .A, count: maxIncrementCount)
        model.increment(molecule: .B, count: maxIncrementCount)

        let equilibrium = model.components.equation.equilibriumConcentrations

        let reactants = equilibrium.reactantA + equilibrium.reactantB
        let products = equilibrium.productC + equilibrium.productD
        XCTAssertEqual(reactants, products, accuracy: 0.00001)
    }

    func testProductMolecules() {
        var model = newModel()
        model.increment(molecule: .A, count: maxIncrementCount)
        model.increment(molecule: .B, count: maxIncrementCount)

        let convergenceC = model.components.equation.equilibriumConcentrations.productC
        let expectedMolecules = (convergenceC * 100).roundedInt()

        // Coeffs are 1, so concentration of C and D should be the same
        XCTAssertEqual(model.beakerCoords[2].count, expectedMolecules)
        XCTAssertEqual(model.beakerCoords[3].count, expectedMolecules)

        let productCoords = model.beakerCoords[2] + model.beakerCoords[3]
        XCTAssertEqual(Set(productCoords).count, productCoords.count)

        let allCoords = model.beakerCoords.flatten
        let reactantCoords = model.beakerCoords[0] + model.beakerCoords[1]

        XCTAssertEqual(Set(allCoords).count, reactantCoords.count)
    }

    func testProductMoleculesDrawingFraction() {
        var model = newModel()
        model.increment(molecule: .A, count: maxIncrementCount)
        model.increment(molecule: .B, count: maxIncrementCount)

        let t = AqueousReactionSettings.timeForConvergence

        func doTest(
            concentration: Equation,
            fractionToDraw: Equation,
            convergence: CGFloat
        ) {
            XCTAssertEqual(fractionToDraw.getY(at: 0), 0)
            XCTAssertEqual(fractionToDraw.getY(at: t), 1)
            let midConcentration = concentration.getY(at: t / 2)
            let midAsRatio = midConcentration / convergence
            XCTAssertEqual(fractionToDraw.getY(at: t / 2), midAsRatio, accuracy: 0.0001)
        }

        func testProducts() {
            doTest(
                concentration: model.components.equation.concentration.productC,
                fractionToDraw: model.components.beakerMolecules[2].animatingMolecules.fractionToDraw,
                convergence: model.components.equation.equilibriumConcentrations.productC
            )
            doTest(
                concentration: model.components.equation.concentration.productD,
                fractionToDraw: model.components.beakerMolecules[3].animatingMolecules.fractionToDraw,
                convergence: model.components.equation.equilibriumConcentrations.productD
            )
        }

        testProducts()


        model = newModel(
            coeffs: BalancedReactionCoefficients(
                reactantA: 2,
                reactantB: 1,
                productC: 1,
                productD: 4)
        )
        model.increment(molecule: .A, count: maxIncrementCount)
        model.increment(molecule: .B, count: maxIncrementCount)

        testProducts()
    }

    func testReverseReactionAddingC() {
        var model = newReverseModel()
        model.beakerCoords.forEach {
            XCTAssertEqual($0.count, maxMolecules / 2)
        }

        let originalCMolecules = model.coords(for: .C)
        let originalOtherMolecules = model.coords(for: .A) + model.coords(for: .B) + model.coords(for: .D)

        model.increment(molecule: .C, count: 1)
        XCTAssertEqual(model.coords(for: .C).count, (maxMolecules / 2) + 1)

        let newMolecules = Set(model.coords(for: .C)).subtracting(Set(originalCMolecules))
        XCTAssertEqual(newMolecules.count, incMolecules)

        newMolecules.forEach { molecule in
            XCTAssertFalse(originalOtherMolecules.contains(molecule))
        }
    }

    func testReverseReactionCAndDIsIncreasedWhenAddingProduct() {
        var model2 = newReverseModel()
        model2.increment(molecule: .C, count: 1)

        let expectedCount = (maxMolecules / 2) + 1
        let expectedConcentration = CGFloat(expectedCount) / 100

        let tAddProd = AqueousReactionSettings.timeToAddProduct

        XCTAssertEqual(model2.concentrations.productC.getY(at: 0), 0)
        XCTAssertEqual(model2.concentrations.productC.getY(at: tAddProd), expectedConcentration, accuracy: 0.00001)

        model2.increment(molecule: .D, count: 1)
        XCTAssertEqual(model2.concentrations.productD.getY(at: 0), 0)
        XCTAssertEqual(model2.concentrations.productD.getY(at: tAddProd), expectedConcentration, accuracy: 0.00001)
    }

    func testConsolidatingMoleculesWithNoOverlap() {
        let grid = GridCoordinate.grid(cols: 1, rows: 100)
        let result = ReactionComponentsWrapper.consolidate(
            molecules: [
                labelledAnimatingMolecules(element: .A, coords: Array(grid[0..<10])),
                labelledAnimatingMolecules(element: .B, coords: Array(grid[10..<20])),
                labelledAnimatingMolecules(element: .C, coords: Array(grid[20..<30])),
                labelledAnimatingMolecules(element: .D, coords: Array(grid[30..<40]))
            ],
            at: 0
        )
        XCTAssertEqual(result.reactantA, Array(grid[0..<10]))
        XCTAssertEqual(result.reactantB, Array(grid[10..<20]))
        XCTAssertEqual(result.productC, Array(grid[20..<30]))
        XCTAssertEqual(result.productD, Array(grid[30..<40]))
    }

    func testConsolidatingMoleculesWithOverlap() {
        let grid = GridCoordinate.grid(cols: 1, rows: 100)
        let result = ReactionComponentsWrapper.consolidate(
            molecules: [
                labelledAnimatingMolecules(element: .A, coords: Array(grid[0..<10])),
                labelledAnimatingMolecules(element: .B, coords: Array(grid[10..<20])),
                labelledAnimatingMolecules(element: .C, coords: Array(grid[5..<11])),
                labelledAnimatingMolecules(element: .D, coords: Array(grid[15..<40]))
            ],
            at: 0
        )

        XCTAssertEqual(result.reactantA, Array(grid[0..<5]))
        XCTAssertEqual(result.reactantB, Array(grid[11..<15]))
        XCTAssertEqual(result.productC, Array(grid[5..<11]))
        XCTAssertEqual(result.productD, Array(grid[15..<40]))
    }

    private func labelledAnimatingMolecules(
        element: AqueousMolecule,
        coords: [GridCoordinate],
        fraction: CGFloat = 1
    ) -> LabelledAnimatingBeakerMolecules {
        LabelledAnimatingBeakerMolecules(
            molecule: element,
            animatingMolecules: AnimatingBeakerMolecules(
                molecules: BeakerMolecules(
                    coords: coords,
                    color: .red
                ),
                fractionToDraw: ConstantEquation(value: fraction)
            )
        )
    }

    private func newReverseModel() -> ReactionComponentsWrapper {
        var forward = newModel()
        forward.increment(molecule: .A, count: maxIncrementCount)
        forward.increment(molecule: .B, count: maxIncrementCount)
        return ReactionComponentsWrapper(
            previous: forward,
            startTime: AqueousReactionSettings.timeToAddProduct,
            equilibriumTime: AqueousReactionSettings.endOfReverseReaction
        )
    }

    private func newModel(
        coeffs: BalancedReactionCoefficients = .unit
    ) -> ReactionComponentsWrapper {
        
        ReactionComponentsWrapper(
            coefficients: coeffs,
            equilibriumConstant: 1,
            cols: 10,
            rows: 10,
            maxRows: 10,
            startTime: 0,
            equilibriumTime: 10
        )
    }

    // Returns number of times to increment reactants to get max concentration. Assumes grid has 100 elements
    private var maxIncrementCount: Int {
        30
    }

    private let maxC = AqueousReactionSettings.ConcentrationInput.maxInitial
    private let incMolecules: Int = 1
    private var maxMolecules: Int = 30
    private var maxConcentration: CGFloat = 0.3
}

private extension ForwardAqueousReactionComponents {
    mutating func incrementA(count: Int) {
        increment(molecule: .A, count: count)
    }

    mutating func incrementB(count: Int) {
        increment(molecule: .B, count: count)
    }
}

private extension ReverseAqueousReactionComponents {
    mutating func incrementC(count: Int) {
        increment(molecule: .C, count: count)
    }

    mutating func incrementD(count: Int) {
        increment(molecule: .D, count: count)
    }
}


private extension ReactionComponentsWrapper {
    var beakerCoords: [[GridCoordinate]] {
        components.beakerMolecules.map { $0.animatingMolecules.molecules.coords }
    }

    func coords(for element: AqueousMolecule) -> [GridCoordinate] {
        components.beakerMolecules.first {
            $0.molecule == element
        }!.animatingMolecules.molecules.coords
    }

    var concentrations: MoleculeValue<Equation> {
        components.equation.concentration
    }
}
