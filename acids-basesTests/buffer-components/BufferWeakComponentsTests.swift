//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import acids_bases

class BufferWeakComponentsTests: XCTestCase {
    
    func testBarChartData() {
        let model = newModel(
            .weakAcid(substanceAddedPerIon: 1),
            settings: .init(
                changeInBarHeightAsFractionOfInitialSubstance: 0.1,
                fractionOfFinalIonMolecules: 0.1
            )
        )

        // Test before any substance has been added
        model.barChartData.forEach { bar in
            XCTAssertEqual(bar.equation.getY(at: 0), 0)
            XCTAssertEqual(bar.equation.getY(at: 1), 0)
        }

        model.incrementSubstance(count: 50)
        XCTAssertEqual(model.barChart(.substance).equation.getY(at: 0), 0.5)
        XCTAssertEqual(model.barChart(.primaryIon).equation.getY(at: 0), 0)
        XCTAssertEqual(model.barChart(.secondaryIon).equation.getY(at: 0), 0)

        XCTAssertEqual(model.barChart(.substance).equation.getY(at: 1), 0.45)
        XCTAssertEqual(model.barChart(.primaryIon).equation.getY(at: 1), 0.05)
        XCTAssertEqual(model.barChart(.secondaryIon).equation.getY(at: 1), 0.05)
    }

    func testBeakerCoords() {
        let model = newModel(
            .weakAcid(substanceAddedPerIon: 1),
            settings: .init(
                changeInBarHeightAsFractionOfInitialSubstance: 0.1,
                fractionOfFinalIonMolecules: 0.1
            )
        )

        XCTAssert(model.molecules(for: .substance).coords.isEmpty)
        XCTAssert(model.molecules(for: .primaryIon).coords.isEmpty)
        XCTAssert(model.molecules(for: .secondaryIon).coords.isEmpty)

        model.incrementSubstance(count: 40)
        XCTAssertEqual(model.molecules(for: .substance).coords.count, 40)
        XCTAssertEqual(model.molecules(for: .primaryIon).coords.count, 4)
        XCTAssertEqual(model.molecules(for: .secondaryIon).coords.count, 4)

        let primaryMolecules = model.molecules(for: .primaryIon)
        let secondaryMolecules = model.molecules(for: .secondaryIon)

        let intersection = Set(primaryMolecules.coords).intersection(secondaryMolecules.coords)
        XCTAssert(intersection.isEmpty)
    }

    private func weakAcid(kA: CGFloat) -> AcidOrBase {
        AcidOrBase.weakAcid(
            secondaryIon: .A,
            substanceAddedPerIon: NonZeroPositiveInt(1)!,
            color: .red,
            kA: kA
        )
    }

    private func newModel(
        _ substance: AcidOrBase,
        settings: BufferWeakSubstanceComponents.Settings
    ) -> BufferWeakSubstanceComponents {
        BufferWeakSubstanceComponents(
            substance: substance,
            settings: settings,
            cols: 10,
            rows: 10
        )
    }
}

private extension BufferWeakSubstanceComponents {
    func barChart(_ substance: SubstancePart) -> BarChartData {
        barChartMap.value(for: substance)
    }
}
