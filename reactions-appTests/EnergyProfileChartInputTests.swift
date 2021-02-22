//
// Reactions App
//

import XCTest
@testable import reactions_app

class EnergyProfileChartInputTests: XCTestCase {

    func testReducedPeakWhenChangingCatalyst() {
        let settings = EnergyProfileShapeSettings(
            peak: 1,
            leftAsymptote: 0.2,
            rightAsymptote: 0.2,
            maxReducedPeak: 0.8,
            minReducedPeak: 0.4,
            minTempEnergy: 0.3,
            maxTempEnergy: 1
        )

        func model(_ catalyst: Catalyst?) -> EnergyProfileChartInput {
            EnergyProfileChartInput(
                shape: settings,
                temperature: 0,
                catalyst: catalyst,
                minTemp: 0,
                maxTemp: 20
            )
        }

        XCTAssertEqual(model(nil).reducedPeak, 1, accuracy: 0.0001)
        XCTAssertEqual(model(.A).reducedPeak, 0.8, accuracy: 0.0001)
        XCTAssertEqual(model(.B).reducedPeak, 0.6, accuracy: 0.0001)
        XCTAssertEqual(model(.C).reducedPeak, 0.4, accuracy: 0.0001)
    }

    func testCurrentEnergyWhenChangingTemperature() {
        let settings = EnergyProfileShapeSettings(
            peak: 1,
            leftAsymptote: 0.2,
            rightAsymptote: 0.2,
            maxReducedPeak: 0.8,
            minReducedPeak: 0.4,
            minTempEnergy: 0.3,
            maxTempEnergy: 1
        )

        func model(_ temp: CGFloat) -> EnergyProfileChartInput {
            EnergyProfileChartInput(
                shape: settings,
                temperature: temp,
                catalyst: .A,
                minTemp: 10,
                maxTemp: 30
            )
        }

        XCTAssertEqual(model(10).reducedPeak, 0.8, accuracy: 0.0001)

        XCTAssertEqual(model(10).currentEnergy, 0.3, accuracy: 0.0001)
        XCTAssertFalse(model(10).canReactToC)

        XCTAssertEqual(model(15).currentEnergy, 0.475, accuracy: 0.0001)
        XCTAssertFalse(model(15).canReactToC)

        XCTAssertEqual(model(20).currentEnergy, 0.65, accuracy: 0.0001)
        XCTAssertFalse(model(20).canReactToC)

        XCTAssertEqual(model(30).currentEnergy, 1, accuracy: 0.0001)
        XCTAssertTrue(model(30).canReactToC)
    }

}
