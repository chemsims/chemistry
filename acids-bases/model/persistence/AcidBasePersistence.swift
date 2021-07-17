//
// Reactions App
//

import Foundation

protocol AcidOrBasePersistence {
    func saveStrongAcid(_ substance: AcidOrBase)
    func saveStrongBase(_ substance: AcidOrBase)

    func getSavedStrongAcid() -> AcidOrBase?
    func getSavedStrongBase() -> AcidOrBase?
}



private struct SharedAcidOrBasePersistence {

    static func saveSubstance(
        _ substance: AcidOrBase,
        ofType type: AcidOrBaseType,
        storeId: (String) -> Void
    ) {
        guard substance.type == type else {
            return
        }
        storeId(substance.id)
    }

    static func readSubstance(withId id: String?, ofType type: AcidOrBaseType) -> AcidOrBase? {
        guard let id = id else {
            return nil
        }
        return AcidOrBase.substances(forType: type).first { substance in
            substance.id == id
        }
    }
}

class InMemoryAcidOrBasePersistence: AcidOrBasePersistence {

    private var strongAcidId: String?
    private var strongBaseId: String?

    func saveStrongAcid(_ substance: AcidOrBase) {
        SharedAcidOrBasePersistence.saveSubstance(substance, ofType: .strongAcid) { id in
            strongAcidId = id
        }
    }

    func saveStrongBase(_ substance: AcidOrBase) {
        SharedAcidOrBasePersistence.saveSubstance(substance, ofType: .strongBase) { id in
            strongBaseId = id
        }
    }

    func getSavedStrongAcid() -> AcidOrBase? {
        SharedAcidOrBasePersistence.readSubstance(withId: strongAcidId, ofType: .strongAcid)
    }

    func getSavedStrongBase() -> AcidOrBase? {
        SharedAcidOrBasePersistence.readSubstance(withId: strongBaseId, ofType: .strongBase)
    }
}

class UserDefaultsAcidOrBasePersistence: AcidOrBasePersistence {

    private let userDefaults = UserDefaults.standard
    private static let strongAcidKey = "acid_bases_strong_acid"
    private static let strongBaseKey = "acid_bases_strong_base"

    func saveStrongAcid(_ substance: AcidOrBase) {
        SharedAcidOrBasePersistence.saveSubstance(substance, ofType: .strongAcid) { id in
            userDefaults.setValue(id, forKey: Self.strongAcidKey)
        }
    }

    func saveStrongBase(_ substance: AcidOrBase) {
        SharedAcidOrBasePersistence.saveSubstance(substance, ofType: .strongBase) { id in
            userDefaults.setValue(id, forKey: Self.strongBaseKey)
        }
    }

    func getSavedStrongAcid() -> AcidOrBase? {
        SharedAcidOrBasePersistence.readSubstance(
            withId: userDefaults.string(forKey: Self.strongAcidKey),
            ofType: .strongAcid
        )
    }

    func getSavedStrongBase() -> AcidOrBase? {
        SharedAcidOrBasePersistence.readSubstance(
            withId: userDefaults.string(forKey: Self.strongBaseKey),
            ofType: .strongBase
        )
    }
}
