//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import acids_bases

class TitrationWeakAcidPreEPModelTests: XCTestCase {

    var substance = AcidOrBase.weakAcids.first!
    
    /// The ion which increases as substance is added to a solution
    private var increasingIon: PrimaryIon {
        substance.primary
    }

    /// The ion which decreases as substance is added to a solution
    private var decreasingIon: PrimaryIon {
        increasingIon.complement
    }

    func testConcentration() {
        let firstModel = TitrationWeakSubstancePreparationModel(substance: substance)
        firstModel.incrementSubstance(count: 20)
        let model = TitrationWeakSubstancePreEPModel(previous: firstModel)

        // Check start concentration is the same the previous one ended at
        TitrationEquationTerm.Concentration.allCases.forEach { term in
            XCTAssertEqualWithTolerance(
                model.currentConcentration.value(for: term),
                firstModel.concentration.value(for: term).getY(at: 1),
                "Failed for \(term)"
            )
        }

        model.incrementTitrant(count: 20)
        let concentration = model.currentConcentration

        let decreasingIonConcentration = concentration.value(for: decreasingIon.concentration)
        let substance = concentration.value(for: .substance)
        let secondary = concentration.value(for: .secondary)

        XCTAssertEqualWithTolerance(decreasingIonConcentration, substance)

        let expectedK = self.substance.type.isAcid ? self.substance.kB : self.substance.kA
        let resultingK = (decreasingIonConcentration * substance) / secondary
        XCTAssertEqualWithTolerance(resultingK, expectedK)
    }

    func testPValues() {
        let firstModel = TitrationWeakSubstancePreparationModel(substance: substance)
        firstModel.incrementSubstance(count: 20)
        firstModel.reactionProgress = 1
        let model = TitrationWeakSubstancePreEPModel(previous: firstModel)

        let initialPValues = model.currentPValues
        XCTAssertEqualWithTolerance(
            initialPValues.value(for: .hydrogen),
            firstModel.currentPValues.value(for: .hydrogen)
        )
        XCTAssertEqualWithTolerance(
            initialPValues.value(for: .hydroxide),
            firstModel.currentPValues.value(for: .hydroxide)
        )

        model.incrementTitrant(count: model.maxTitrant)

        let finalPValues = model.currentPValues

        XCTAssertEqualWithTolerance(
            finalPValues.value(for: .hydrogen),
            -log10(model.currentConcentration.value(for: .hydrogen))
        )
        XCTAssertEqualWithTolerance(
            finalPValues.value(for: .hydroxide),
            -log10(model.currentConcentration.value(for: .hydroxide))
        )

        // Check the equation pH = pKa + log([A]/[HA]) holds

        let secondaryConcentration = model.currentConcentration.value(for: .secondary)
        let substanceConcentration = model.currentConcentration.value(for: .substance)

        let pK = substance.type.isAcid ? substance.pKA : substance.pKB
        let pIncreasingIonFromPKEquation = pK + log10(secondaryConcentration / substanceConcentration)

        XCTAssertEqualWithTolerance(
            finalPValues.value(for: increasingIon.pValue), pIncreasingIonFromPKEquation
        )

        // Check the equation 14 = pH + pOH holds
        XCTAssertEqualWithTolerance(
            finalPValues.value(for: .hydroxide) + finalPValues.value(for: .hydrogen),
            14
        )
    }

    func testVolume() {
        let firstModel = TitrationWeakSubstancePreparationModel(substance: substance)
        firstModel.incrementSubstance(count: 20)
        let model = TitrationWeakSubstancePreEPModel(previous: firstModel)

        let expectedInitialVolume = firstModel.volume.value(for: .substance)
        XCTAssertEqual(model.currentVolume.value(for: .substance), expectedInitialVolume)
        XCTAssertEqual(
            model.currentVolume.value(for: .initialSubstance), expectedInitialVolume
        )
        XCTAssertEqual(model.currentVolume.value(for: .titrant), 0)

        model.incrementTitrant(count: model.maxTitrant)
        let finalTitrantVolume = model.currentVolume.value(for: .titrant)

        // Check the equation n-initial-substance = V-titrant * M-titrant
        let resultingMoles = finalTitrantVolume * model.molarity.value(for: .titrant)
        let expectedMoles = firstModel.moles.value(for: .substance).getY(at: 1)
        XCTAssertEqualWithTolerance(resultingMoles, expectedMoles)
    }

    func testMoles() {
        let firstModel = TitrationWeakSubstancePreparationModel(substance: substance)
        firstModel.incrementSubstance(count: 20)
        let model = TitrationWeakSubstancePreEPModel(previous: firstModel)

        let initialSubstanceMoles = firstModel.moles.value(for: .substance).getY(at: 1)
        XCTAssertEqual(model.currentMoles.value(for: .initialSubstance), initialSubstanceMoles)
        XCTAssertEqualWithTolerance(
            model.currentMoles.value(for: .substance),
            initialSubstanceMoles
        )

        let initialSecondaryMoles = firstModel.moles.value(for: .secondary).getY(at: 1)
        XCTAssertEqual(
            model.currentMoles.value(for: .initialSecondary),
            initialSecondaryMoles
        )
        XCTAssertEqual(
            model.currentMoles.value(for: .secondary),
            initialSecondaryMoles
        )

        XCTAssertEqual(model.currentMoles.value(for: .titrant), 0)

        model.incrementTitrant(count: model.maxTitrant)

        XCTAssertEqual(model.currentMoles.value(for: .initialSubstance), initialSubstanceMoles)

        // We expect a value of 0 so can't use tolerance here as is uses a percentage
        XCTAssertEqual(model.currentMoles.value(for: .substance), 0, accuracy: 1e-10)

        XCTAssertEqualWithTolerance(model.currentMoles.value(for: .titrant), initialSubstanceMoles)
    }

    func testBarChartData() {
        let firstModel = TitrationWeakSubstancePreparationModel(substance: substance)
        firstModel.incrementSubstance(count: 20)
        let model = TitrationWeakSubstancePreEPModel(previous: firstModel)

        ExtendedSubstancePart.allCases.forEach { part in
            let initialBarChart = firstModel.barChartDataMap.value(for: part).equation
            let currentBarChart = model.barChartDataMap.value(for: part).equation
            XCTAssertEqual(initialBarChart.getY(at: 1), currentBarChart.getY(at: 0))
        }
    }

    func testInputLimits() {
        let firstModel = TitrationWeakSubstancePreparationModel()
        firstModel.incrementSubstance(count: 20)

        let model = TitrationWeakSubstancePreEPModel(previous: firstModel)

        XCTAssert(model.canAddTitrant)
        XCTAssertFalse(model.hasAddedEnoughTitrant)

        model.incrementTitrant(count: 50)

        XCTAssertFalse(model.canAddTitrant)
        XCTAssert(model.hasAddedEnoughTitrant)
        XCTAssertEqual(model.titrantAdded, 20)
    }
}

extension TitrationWeakSubstancePreEPModel {
    var currentConcentration: EnumMap<TitrationEquationTerm.Concentration, CGFloat> {
        concentration.map { $0.getY(at: CGFloat(titrantAdded)) }
    }

    var currentPValues: EnumMap<TitrationEquationTerm.PValue, CGFloat> {
        equationData.pValues.map { $0.getY(at: CGFloat(titrantAdded)) }
    }

    var currentVolume: EnumMap<TitrationEquationTerm.Volume, CGFloat> {
        volume.map { $0.getY(at: CGFloat(titrantAdded)) }
    }

    var currentMoles: EnumMap<TitrationEquationTerm.Moles, CGFloat> {
        equationData.moles.map { $0.getY(at: CGFloat(titrantAdded)) }
    }
}
