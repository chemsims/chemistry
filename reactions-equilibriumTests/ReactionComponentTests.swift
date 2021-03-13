//
// Reactions App
//

import XCTest
@testable import reactions_equilibrium
@testable import ReactionsCore

class ReactionComponentTests: XCTestCase {

    func testIncrementingAMolecules() {
        var model = newModel()

        XCTAssert(model.aMolecules.coordinates.isEmpty)
        XCTAssert(model.bMolecules.coordinates.isEmpty)
        XCTAssert(model.cMolecules.isEmpty)
        XCTAssert(model.dMolecules.isEmpty)

        model.incrementA(count: 1)

        XCTAssertEqual(model.aMolecules.coordinates.count, 1)
        model.incrementA(count: 1)
        XCTAssertEqual(model.aMolecules.coordinates.count, 2)
    }

    func testIncrementingAMoleculesToMaxCount() {
        var model = newModel()

        XCTAssert(model.canIncrement(molecule: .A))
        model.incrementA(count: maxIncrementCount)

        XCTAssertEqual(model.aMolecules.coordinates.count, maxMolecules)
        XCTAssertFalse(model.canIncrement(molecule: .A))

        model.incrementA(count: 1)
        XCTAssertEqual(model.aMolecules.coordinates.count, maxMolecules)
    }

    func testIncrementingBMolecules() {
        var model = newModel()
        model.incrementA(count: maxIncrementCount)
        model.incrementB(count: maxIncrementCount)

        XCTAssertEqual(model.aMolecules.coordinates.count, maxMolecules)
        XCTAssertEqual(model.bMolecules.coordinates.count, maxMolecules)

        model.bMolecules.coordinates.forEach { molecule in
            XCTAssertFalse(model.aMolecules.coordinates.contains(molecule))
        }
    }

    func testA0AndB0AreCorrect() {
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

        let allCoords = model.aMolecules.coordinates + model.bMolecules.coordinates + model.cMolecules + model.dMolecules
        let reactantCoords = model.aMolecules.coordinates + model.bMolecules.coordinates

        XCTAssertEqual(Set(allCoords).count, reactantCoords.count)
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
            XCTAssertEqual(fractionToDraw.getY(at: t / 2), midAsRatio)
        }

        func testProducts() {
            doTest(
                concentration: model.equations.productC,
                fractionToDraw: model.animatingMolecules[2].fractionToDraw,
                convergence: model.equations.convergenceC
            )
            doTest(
                concentration: model.equations.productD,
                fractionToDraw: model.animatingMolecules[3].fractionToDraw,
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
        XCTAssertEqual(model.aMolecules.count, maxMolecules / 2)
        XCTAssertEqual(model.bMolecules.count, maxMolecules / 2)
        XCTAssertEqual(model.cMolecules.count, maxMolecules / 2)
        XCTAssertEqual(model.dMolecules.count, maxMolecules / 2)

        let originalCMolecules = model.cMolecules
        let originalOtherMolecules = model.aMolecules + model.bMolecules + model.dMolecules

        model.increment(molecule: .C, count: 1)
        XCTAssertEqual(model.cMolecules.count, (maxMolecules / 2) + 1)

        let newMolecules = Set(model.cMolecules).subtracting(Set(originalCMolecules))
        XCTAssertEqual(newMolecules.count, incMolecules)

        newMolecules.forEach { molecule in
            XCTAssertFalse(originalOtherMolecules.contains(molecule))
        }
    }

    func testReverseReactionCAndDIsIncreasedWhenAddingProduct() {
        var model = newReverseModel()

        model.increment(molecule: .C, count: 1)
        let expectedCount = (maxMolecules / 2) + 1
        let expectedConcentration = CGFloat(expectedCount) / 100

        let tAddProd = AqueousReactionSettings.timeToAddProduct

        XCTAssertEqual(model.equations.productC.getY(at: 0), 0)
        XCTAssertEqual(model.equations.productC.getY(at: tAddProd), expectedConcentration, accuracy: 0.00001)

        model.increment(molecule: .D, count: 1)
        XCTAssertEqual(model.equations.productD.getY(at: 0), 0)
        XCTAssertEqual(model.equations.productD.getY(at: tAddProd), expectedConcentration, accuracy: 0.00001)
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
            equilibriumConstant: 1,
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

