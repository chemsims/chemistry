//
// Reactions App
//

import SwiftUI

class TipOverlayViewModel: ObservableObject {

    init(persistence: TipOverlayPersistence) {
        self.persistence = persistence
    }

    @Published private(set) var showModal = false
    private var persistence: TipOverlayPersistence

    func show() {
        withAnimation(.easeOut(duration: 0.25)) {
            showModal = true
        }
        persistence.hasSeenTipScreen = true
    }

    func dismiss() {
        withAnimation(.easeOut(duration: 0.25)) {
            showModal = false
        }
    }

    func shouldShowTipOverlay() -> Bool {
        !persistence.hasSeenTipScreen
    }
}

protocol TipOverlayPersistence {
    var hasSeenTipScreen: Bool { get set }
}

class UserDefaultsTipOverlayPersistence: TipOverlayPersistence {
    private static let key = "seenSupportStudentsModal"

    var hasSeenTipScreen: Bool {
        get { userDefaults.bool(forKey: Self.key) }
        set {
            userDefaults.setValue(newValue, forKey: Self.key)
        }
    }

    private let userDefaults = UserDefaults.standard

}
