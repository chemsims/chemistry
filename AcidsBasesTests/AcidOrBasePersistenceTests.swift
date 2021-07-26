//
// Reactions App
//

import XCTest
@testable import AcidsBases

class AcidOrBasePersistenceTests: XCTestCase {

    override func setUp() {
        UserDefaults.standard.clearAll()
    }

    func testInMemoryPersistence() {
        doTestPersistence(InMemoryAcidOrBasePersistence())
    }

    func testUserDefaultsPersistence() {
        doTestPersistence(UserDefaultsAcidOrBasePersistence())
    }

    private func doTestPersistence(_ model: AcidOrBasePersistence) {
        // Test strong acid
        doTestPersistenceForGeneralSubstance(
            model,
            getSaved: { $0.getSavedStrongAcid() },
            doSave: { $0.saveStrongAcid($1) },
            validSubstances: AcidOrBase.strongAcids,
            invalidSubstances: AcidOrBase.strongBases + AcidOrBase.weakAcids + AcidOrBase.weakBases
        )

        // test strong base
        doTestPersistenceForGeneralSubstance(
            model,
            getSaved: { $0.getSavedStrongBase() },
            doSave: { $0.saveStrongBase($1) },
            validSubstances: AcidOrBase.strongBases,
            invalidSubstances: AcidOrBase.strongAcids + AcidOrBase.weakAcids + AcidOrBase.weakBases
        )
    }

    private func doTestPersistenceForGeneralSubstance(
        _ model: AcidOrBasePersistence,
        getSaved: (AcidOrBasePersistence) -> AcidOrBase?,
        doSave: (AcidOrBasePersistence, AcidOrBase) -> Void,
        validSubstances: [AcidOrBase],
        invalidSubstances: [AcidOrBase]
    ) {
        XCTAssertNil(getSaved(model))

        invalidSubstances.forEach { invalidSubstance in
            doSave(model, invalidSubstance)
            XCTAssertNil(getSaved(model))
        }

        validSubstances.forEach { validSubstance in
            doSave(model, validSubstance)
            XCTAssertEqual(getSaved(model), validSubstance)
        }
    }
}
