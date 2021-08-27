//
// Reactions App
//

import SwiftUI

public class SharePromptViewModel: ObservableObject {

    public init(persistence: SharePromptPersistence) {
        self.persistence = persistence
    }

    @Published public var showPrompt = true
    private let persistence: SharePromptPersistence

    public func show() {
        withAnimation(.easeOut(duration: 0.25)) {
            showPrompt = true
        }
        savePersistenceShown()
    }

    public func dismiss() {
        withAnimation(.easeOut(duration: 0.25)) {
            showPrompt = false
        }
    }

    // TODO
    func shouldShowPrompt() -> Bool {
        true
    }

    private func savePersistenceShown() {
        let lastPrompt = persistence.getLastPromptInfo()
        let thisPrompt = lastPrompt?.increment() ?? .firstPrompt()
        persistence.setSharePromptInfo(thisPrompt)
    }
}
