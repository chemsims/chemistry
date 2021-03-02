//
// Reactions App
//

import XCTest
@testable import reactions_equilibrium
@testable import ReactionsCore

class ForwardReactionComponentTests: XCTestCase {

    func testIncrementingAMolecules() {
        var model = newModel()

        XCTAssert(model.aMolecules.isEmpty)
        XCTAssert(model.bMolecules.isEmpty)
        XCTAssert(model.cMolecules.isEmpty)
        XCTAssert(model.dMolecules.isEmpty)

        model.incrementA()

        let incMolecule = (incC * 100).roundedInt()

        XCTAssertEqual(model.aMolecules.count, incMolecule)
        model.incrementA()
        XCTAssertEqual(model.aMolecules.count, 2 * incMolecule)
    }

    func testIncrementingAMoleculesToMaxCount() {
        var model = newModel()
        model.incrementA(count: maxIncrementCount)

        XCTAssertEqual(model.aMolecules.count, maxMolecules)
        model.incrementA()
        XCTAssertEqual(model.aMolecules.count, maxMolecules)
    }

    func testIncrementingBMolecules() {
        var model = newModel()
        model.incrementA(count: maxIncrementCount)
        model.incrementB(count: maxIncrementCount)

        XCTAssertEqual(model.aMolecules.count, maxMolecules)
        XCTAssertEqual(model.bMolecules.count, maxMolecules)

        model.bMolecules.forEach { molecule in
            XCTAssertFalse(model.aMolecules.contains(molecule))
        }
    }

    func testA0AndB0AreCorrect(){
        var model = newModel()
        model.incrementA(count: maxIncrementCount)
        model.incrementB(count: maxIncrementCount)

        XCTAssertEqual(model.equations.reactantA.getY(at: 0), maxConcentration, accuracy: 0.0001)
        XCTAssertEqual(model.equations.reactantB.getY(at: 0), maxConcentration, accuracy: 0.0001)
    }

    func testEquationConverges() {
        var model = newModel()
        model.incrementA(count: maxIncrementCount)
        model.incrementB(count: maxIncrementCount)

        let reactants = model.equations.convergenceA + model.equations.convergenceB
        let products = model.equations.convergenceC + model.equations.convergenceD
        XCTAssertEqual(reactants, products, accuracy: 0.00001)
    }

    func testProductMolecules() {
        var model = newModel()
        model.incrementA(count: maxIncrementCount)
        model.incrementB(count: maxIncrementCount)

        let convergenceC = model.equations.convergenceC
        let expectedMolecules = (convergenceC * 100).roundedInt()

        // Coeffs are 1, so concentration of C and D should be the same
        XCTAssertEqual(model.cMolecules.count, expectedMolecules)
        XCTAssertEqual(model.dMolecules.count, expectedMolecules)

        let productCoords = model.cMolecules + model.dMolecules
        XCTAssertEqual(Set(productCoords).count, productCoords.count)

        let allCoords = model.aMolecules + model.bMolecules + model.cMolecules + model.dMolecules
        let reactantCoords = model.aMolecules + model.bMolecules

        XCTAssertEqual(Set(allCoords).count, reactantCoords.count)
    }

    func testReactantMoleculesDrawingFraction() {
        var model = newModel()
        model.incrementA(count: maxIncrementCount)
        model.incrementB(count: maxIncrementCount)
        let t = AqueousReactionSettings.timeForConvergence

        XCTAssertEqual(model.aBeakerFractionToDraw.getY(at: 0), 1)
        XCTAssertEqual(model.aBeakerFractionToDraw.getY(at: t), 1)

        XCTAssertEqual(model.bBeakerFractionToDraw.getY(at: 0), 1)
        XCTAssertEqual(model.bBeakerFractionToDraw.getY(at: t), 1)
    }

    func testProductMoleculesDrawingFraction() {
        var model = newModel()
        model.incrementA(count: maxIncrementCount)
        model.incrementB(count: maxIncrementCount)
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
            XCTAssertEqual(model.cBeakerFractionToDraw.getY(at: t / 2), midAsRatio)
        }

        func testProducts() {
            doTest(
                concentration: model.equations.productC,
                fractionToDraw: model.cBeakerFractionToDraw,
                convergence: model.equations.convergenceC
            )
            doTest(
                concentration: model.equations.productD,
                fractionToDraw: model.dBeakerFractionToDraw,
                convergence: model.equations.convergenceD
            )
        }

        testProducts()

        model = newModel(coeffs: BalancedReactionCoefficients(reactantA: 2, reactantB: 1, productC: 1, productD: 4))
        model.incrementA(count: maxIncrementCount)
        model.incrementB(count: maxIncrementCount)

        testProducts()
    }

    func testReverseReactionAddingC() {
        var model = newReverseModel()
        XCTAssertEqual(model.aMolecules.count, maxMolecules)
        XCTAssertEqual(model.bMolecules.count, maxMolecules)
        XCTAssertEqual(model.cMolecules.count, maxMolecules / 2)
        XCTAssertEqual(model.dMolecules.count, maxMolecules / 2)

        let originalCMolecules = model.cMolecules
        let originalOtherMolecules = model.aMolecules + model.bMolecules + model.dMolecules

        model.incrementC()
        XCTAssertEqual(model.cMolecules.count, (maxMolecules / 2) + incMolecules)

        let newMolecules = Set(model.cMolecules).subtracting(Set(originalCMolecules))
        XCTAssertEqual(newMolecules.count, incMolecules)

        newMolecules.forEach { molecule in
            XCTAssertFalse(originalOtherMolecules.contains(molecule))
        }
    }

    func testReverseReactionCAndDIsIncreasedWhenAddingProduct() {
        var model = newReverseModel()

        model.incrementC()
        let expectedCount = (maxMolecules / 2) + incMolecules
        let expectedConcentration = CGFloat(expectedCount) / 100

        let equation = model.equations.productC
        let tAddProd = AqueousReactionSettings.timeToAddProduct

        XCTAssertEqual(equation.getY(at: 0), 0)
        XCTAssertEqual(equation.getY(at: tAddProd), expectedConcentration)
    }

    private func newReverseModel() -> ReverseAqueousReactionComponents {
        ReverseAqueousReactionComponents(forwardReaction: newModel(maxC: true))
    }


    private func newModel(
        coeffs: BalancedReactionCoefficients = .unit,
        maxC: Bool = false
    ) -> ForwardAqueousReactionComponents {
        var model = ForwardAqueousReactionComponents(
            coefficients: coeffs,
            availableCols: 10,
            availableRows: 10
        )
        if maxC {
            model.incrementA(count: maxIncrementCount)
            model.incrementB(count: maxIncrementCount)
        }
        return model
    }

    // Returns number of times to increment reactants to get max concentration. Assumes grid has 100 elements
    private var maxIncrementCount: Int {
        Int(ceil(Double(maxMolecules) / Double(incMolecules)))
    }


    private let maxC = AqueousReactionSettings.ConcentrationInput.maxInitial
    private let incC = AqueousReactionSettings.ConcentrationInput.cToIncrement
    private var incMolecules: Int {
        (incC * 100).roundedInt()
    }
    private var maxMolecules: Int {
        (maxC * 100).roundedInt()
    }
    private var maxConcentration: CGFloat {
        CGFloat(maxMolecules) / 100
    }
}

private extension ForwardAqueousReactionComponents {
    mutating func incrementA(count: Int) {
        doIncrement(count, { incrementA() })
    }

    mutating func incrementB(count: Int) {
        doIncrement(count, { incrementB() })
    }
}

private extension ReverseAqueousReactionComponents {
    mutating func incrementC(count: Int) {
        doIncrement(count, { incrementC() })
    }

    mutating func incrementD(count: Int) {
        doIncrement(count, { incrementD() })
    }
}

private extension AqueousReactionComponents {
    fileprivate func doIncrement(_ count: Int, _ action: () -> Void) {
        (0..<count).forEach { _ in action() }
    }
}

private extension BalancedReactionEquations {
    var convergenceA: CGFloat {
        convergence(of: reactantA)
    }

    var convergenceB: CGFloat {
        convergence(of: reactantB)
    }

    var convergenceC: CGFloat {
        convergence(of: productC)
    }

    var convergenceD: CGFloat {
        convergence(of: productD)
    }

    private func convergence(of equation: Equation) -> CGFloat {
        equation.getY(at: convergenceTime)
    }
}
