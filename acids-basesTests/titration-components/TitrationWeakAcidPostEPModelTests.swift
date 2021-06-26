//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import acids_bases

class TitrationWeakAcidPostEPModelTests: XCTestCase {

    var substance = AcidOrBase.weakAcids.first!

    private var primaryIon: PrimaryIon {
        substance.primary
    }
    private var complementIon: PrimaryIon {
        primaryIon.complement
    }

    func testConcentration() {
        let firstModel = TitrationWeakSubstancePreparationModel(
            substance: substance,
            settings: .withDefaults(
                finalMaxPValue: 12
            )
        )
        firstModel.incrementSubstance(count: 20)
        let secondModel = TitrationWeakSubstancePreEPModel(previous: firstModel)
        secondModel.incrementTitrant(count: secondModel.maxTitrant)
        let model = TitrationWeakSubstancePostEPModel(previous: secondModel)

        func checkTheSameAsPrevious(_ term: TitrationEquationTerm.Concentration) {
            let previous = secondModel.currentConcentration.value(for: term)
            let current = model.currentConcentration.value(for: term)
            XCTAssertEqualWithTolerance(current, previous)
        }
        checkTheSameAsPrevious(.hydrogen)
        checkTheSameAsPrevious(.hydroxide)
        checkTheSameAsPrevious(.substance)
        checkTheSameAsPrevious(.secondary)

        model.incrementTitrant(count: model.maxTitrant)
        let finalPrimaryConcentration = model.currentConcentration.value(for: primaryIon.concentration)
        let finalComplementConcentration = model.currentConcentration.value(for: complementIon.concentration)

        XCTAssertEqualWithTolerance(finalComplementConcentration, 1e-2)
        XCTAssertEqualWithTolerance(finalPrimaryConcentration, 1e-12)
    }

    func testPValues() {
        let firstModel = TitrationWeakSubstancePreparationModel(
            substance: substance,
            settings: .withDefaults(
                finalMaxPValue: 12
            )
        )
        firstModel.incrementSubstance(count: 20)
        let secondModel = TitrationWeakSubstancePreEPModel(previous: firstModel)
        secondModel.incrementTitrant(count: secondModel.maxTitrant)
        let model = TitrationWeakSubstancePostEPModel(previous: secondModel)

        func checkTheSameAsPrevious(_ term: TitrationEquationTerm.PValue) {
            let previous = secondModel.currentPValues.value(for: term)
            let current = model.currentPValues.value(for: term)
            XCTAssertEqualWithTolerance(current, previous)
        }
        checkTheSameAsPrevious(.hydrogen)
        checkTheSameAsPrevious(.hydroxide)

        model.incrementTitrant(count: model.maxTitrant)
        XCTAssertEqualWithTolerance(model.currentPValues.value(for: primaryIon.pValue), 12)
        XCTAssertEqualWithTolerance(model.currentPValues.value(for: complementIon.pValue), 2)
    }

    func testVolume() {
        let firstModel = TitrationWeakSubstancePreparationModel(
            settings: .withDefaults(
                finalMaxPValue: 12
            )
        )
        firstModel.incrementSubstance(count: 20)
        let secondModel = TitrationWeakSubstancePreEPModel(previous: firstModel)
        secondModel.incrementTitrant(count: secondModel.maxTitrant)
        let model = TitrationWeakSubstancePostEPModel(previous: secondModel)

        let previousTitrant = secondModel.currentVolume.value(for: .titrant)
        let previousSubstance = secondModel.currentVolume.value(for: .initialSubstance)
        let expectedEquivalenceVolume = previousTitrant + previousSubstance

        XCTAssertEqual(model.currentVolume.value(for: .titrant), 0)
        XCTAssertEqual(
            model.currentVolume.value(for: .equivalencePoint),
            expectedEquivalenceVolume
        )

        model.incrementTitrant(count: model.maxTitrant)
        let finalTitrantVolume = model.currentVolume.value(for: .titrant)

        // check we satisfy the equation:
        // [OH] = n-koh / (V-e + V-koh)
        //      = (V-koh * M-koh) / (V-e + V-koh)
        let numer = finalTitrantVolume * model.molarity.value(for: .titrant)
        let denom = expectedEquivalenceVolume + finalTitrantVolume
        XCTAssertEqual(numer / denom, 1e-2)
    }

    func testMoles() {
        let firstModel = TitrationWeakSubstancePreparationModel()
        firstModel.incrementSubstance(count: 20)
        let secondModel = TitrationWeakSubstancePreEPModel(previous: firstModel)
        secondModel.incrementTitrant(count: secondModel.maxTitrant)
        let model = TitrationWeakSubstancePostEPModel(previous: secondModel)

        XCTAssertEqual(model.currentMoles.value(for: .titrant), 0)

        model.incrementTitrant(count: model.maxTitrant)

        XCTAssertEqual(
            model.currentMoles.value(for: .titrant),
            model.molarity.value(for: .titrant) * model.currentVolume.value(for: .titrant)
        )
    }

    func testBarChartData() {
        let firstModel = TitrationWeakSubstancePreparationModel()
        firstModel.incrementSubstance(count: 20)
        let secondModel = TitrationWeakSubstancePreEPModel(previous: firstModel)
        secondModel.incrementTitrant(count: secondModel.maxTitrant)
        let model = TitrationWeakSubstancePostEPModel(previous: secondModel)

        ExtendedSubstancePart.allCases.forEach { part in
            let initialBarChart = secondModel.barChartDataMap.value(for: part).equation
            let currentBarChart = model.barChartDataMap.value(for: part).equation
            XCTAssertEqual(
                initialBarChart.getY(at: CGFloat(secondModel.maxTitrant)),
                currentBarChart.getY(at: 0),
                "Failed for \(part)"
            )
        }
    }

    func testInputLimits() {
        let firstModel = TitrationWeakSubstancePreparationModel()
        firstModel.incrementSubstance(count: 20)

        let secondModel = TitrationWeakSubstancePreEPModel(previous: firstModel)
        secondModel.incrementTitrant(count: secondModel.maxTitrant)

        let model = TitrationWeakSubstancePostEPModel(previous: secondModel)

        XCTAssert(model.canAddTitrant)
        XCTAssertFalse(model.hasAddedEnoughTitrant)

        model.incrementTitrant(count: 42)

        XCTAssertFalse(model.canAddTitrant)
        XCTAssert(model.hasAddedEnoughTitrant)
        XCTAssertEqual(model.titrantAdded, 40)
    }
}

extension TitrationWeakSubstancePostEPModel {
    var currentConcentration: EnumMap<TitrationEquationTerm.Concentration, CGFloat> {
        concentration.map { $0.getY(at: CGFloat(titrantAdded)) }
    }

    var currentVolume: EnumMap<TitrationEquationTerm.Volume, CGFloat> {
        volume.map { $0.getY(at: CGFloat(titrantAdded)) }
    }

    var currentMoles: EnumMap<TitrationEquationTerm.Moles, CGFloat> {
        moles.map { $0.getY(at: CGFloat(titrantAdded)) }
    }

    var currentPValues: EnumMap<TitrationEquationTerm.PValue, CGFloat> {
        equationData.pValues.map { $0.getY(at: CGFloat(titrantAdded)) }
    }
}
