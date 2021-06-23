//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import acids_bases

class TitrationWeakSubstancePostEPModelTests: XCTestCase {
    func testConcentration() {
        let firstModel = TitrationWeakSubstancePreparationModel(
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
            XCTAssertEqual(current, previous)
        }
        checkTheSameAsPrevious(.hydrogen)
        checkTheSameAsPrevious(.hydroxide)
        checkTheSameAsPrevious(.substance)
        checkTheSameAsPrevious(.secondary)

        model.incrementTitrant(count: model.maxTitrant)
        let finalHConcentration = model.currentConcentration.value(for: .hydrogen)
        let finalOHConcentration = model.currentConcentration.value(for: .hydroxide)

        XCTAssertEqual(finalOHConcentration, 1e-2)
        XCTAssertEqual(finalHConcentration, 1e-12)
    }

    func testPValues() {
        let firstModel = TitrationWeakSubstancePreparationModel(
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
            XCTAssertEqual(current, previous)
        }
        checkTheSameAsPrevious(.hydrogen)
        checkTheSameAsPrevious(.hydroxide)

        model.incrementTitrant(count: model.maxTitrant)
        XCTAssertEqual(model.currentPValues.value(for: .hydrogen), 12)
        XCTAssertEqual(model.currentPValues.value(for: .hydroxide), 2)
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
        let numer = finalTitrantVolume * model.titrantMolarity
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
            model.titrantMolarity * model.currentVolume.value(for: .titrant)
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
        pValues.map { $0.getY(at: CGFloat(titrantAdded)) }
    }
}
